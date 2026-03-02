import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/location_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/star_rating_widget.dart';
import '../../../shared/widgets/cascading_location_widget.dart';
import '../repositories/writer_list_repository.dart';
import '../repositories/location_repository.dart';
import '../../../shared/providers/dio_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _writers = [];
  int _page = 1, _totalPages = 1, _total = 0;
  bool _loading = false;
  bool _loadingDivisions = false;
  bool _locating = false;
  int? _divId, _distId, _upaId;
  int? _initialDivId, _initialDistId;
  int _filterKey = 0; // increment to force CascadingLocationWidget rebuild
  List<DivisionModel> _divisions = [];
  late WriterListRepository _writerRepo;
  late LocationRepository _locationRepo;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _writerRepo = WriterListRepository(ref.read(dioProvider));
    _locationRepo = LocationRepository(ref.read(dioProvider));
    setState(() => _loadingDivisions = true);
    _locationRepo.getDivisions().then((list) {
      if (mounted) setState(() { _divisions = list; _loadingDivisions = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loadingDivisions = false);
    });
    _fetchWriters();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchWriters({int page = 1}) async {
    setState(() { _loading = true; _page = page; });
    try {
      final result = await _writerRepo.getWriters(
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        divisionId: _divId,
        districtId: _distId,
        upazilaId: _upaId,
        page: page,
      );
      setState(() {
        _writers = result['writers'] as List<UserModel>;
        _total = result['total'] as int;
        _totalPages = result['last_page'] as int;
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Normalize a place name for fuzzy matching against API names
  String _norm(String s) {
    return s.toLowerCase()
        .replaceAll(' division', '')
        .replaceAll(' district', '')
        .replaceAll(' zila', '')
        .trim();
  }

  bool _nameMatches(String geocoded, String apiName) {
    final g = _norm(geocoded);
    final a = _norm(apiName);
    if (g.isEmpty) return false;
    if (g == a || a.contains(g) || g.contains(a)) return true;
    // Check alias map (e.g. chittagong → chattogram)
    final alias = AppConstants.districtAliasMap[g];
    if (alias != null && (alias == a || a.contains(alias))) return true;
    return false;
  }

  Future<void> _useGeolocation() async {
    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services on your device')),
          );
        }
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission permanently denied. Enable it in Settings.'),
              action: SnackBarAction(label: 'Settings', onPressed: () => Geolocator.openAppSettings()),
            ),
          );
        }
        return;
      }
      if (perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not determine your area. Try again.')),
          );
        }
        return;
      }

      final place = placemarks.first;
      // administrativeArea = Division, subAdministrativeArea = District
      final adminArea = place.administrativeArea ?? '';
      final subAdmin = place.subAdministrativeArea ?? '';
      final locality = place.locality ?? '';

      // Match division
      int? matchedDivId;
      for (final div in _divisions) {
        if (_nameMatches(adminArea, div.name) ||
            _nameMatches(locality, div.name)) {
          matchedDivId = div.id;
          break;
        }
      }

      if (matchedDivId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Area not matched: $adminArea. Showing all writers.')),
          );
          _fetchWriters();
        }
        return;
      }

      // Load districts for matched division
      final districts = await _locationRepo.getDistricts(matchedDivId);

      // Match district
      int? matchedDistId;
      for (final dist in districts) {
        if (_nameMatches(subAdmin, dist.name) ||
            _nameMatches(locality, dist.name) ||
            _nameMatches(adminArea, dist.name)) {
          matchedDistId = dist.id;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        _divId = matchedDivId;
        _distId = matchedDistId;
        _upaId = null;
        _initialDivId = matchedDivId;
        _initialDistId = matchedDistId;
        _showFilters = true;
        _filterKey++; // force CascadingLocationWidget to rebuild with new initials
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          matchedDistId != null
            ? 'Filtering by your district'
            : 'Filtering by your division: $adminArea',
        )),
      );
      _fetchWriters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.description, size: 16, color: Colors.white)),
          const SizedBox(width: 8),
          const Text.rich(TextSpan(children: [
            TextSpan(text: 'Dolil', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gray900)),
            TextSpan(text: 'BD', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ])),
        ]),
        actions: [
          TextButton(onPressed: () => context.push('/login'), child: const Text('Sign In')),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () => context.push('/register'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
              child: const Text('Register'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, Color(0xFF1E40AF)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(children: [
              const Text('Find Certified Deed Writers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Connect with verified legal document professionals in Bangladesh', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Search
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(hintText: 'Search writers...', prefixIcon: Icon(Icons.search), border: InputBorder.none, filled: false, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                    onSubmitted: (_) => _fetchWriters(),
                  )),
                  _locating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(onPressed: _useGeolocation, icon: const Icon(Icons.my_location, color: AppColors.primary), tooltip: 'Use my location'),
                  ElevatedButton(
                    onPressed: () => _fetchWriters(),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 4),
                ]),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                label: const Text('Filters', style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),

          // Filters panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.gray100,
              child: CascadingLocationWidget(
                key: ValueKey(_filterKey),
                divisions: _divisions,
                initialDivisionId: _initialDivId,
                initialDistrictId: _initialDistId,
                loadDistricts: _locationRepo.getDistricts,
                loadUpazilas: _locationRepo.getUpazilas,
                onChanged: (div, dist, upa) {
                  _divId = div; _distId = dist; _upaId = upa;
                  _fetchWriters();
                },
              ),
            ),

          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(children: [
              Text('$_total deed writers found', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray700)),
              const Spacer(),
              if (_loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),
          ),

          // Writer grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _loading && _writers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.75),
                  itemCount: _writers.length,
                  itemBuilder: (_, i) => _WriterCard(writer: _writers[i]),
                ),
          ),

          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(onPressed: _page > 1 ? () => _fetchWriters(page: _page - 1) : null, icon: const Icon(Icons.chevron_left)),
                Text('$_page / $_totalPages', style: const TextStyle(color: AppColors.gray600)),
                IconButton(onPressed: _page < _totalPages ? () => _fetchWriters(page: _page + 1) : null, icon: const Icon(Icons.chevron_right)),
              ]),
            ),

          // How It Works
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Text('How It Works', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gray900)),
              const SizedBox(height: 20),
              _howItWorksStep(1, 'Search', 'Find certified deed writers near you', Icons.search),
              _howItWorksStep(2, 'Book', 'Schedule an appointment online', Icons.calendar_today_outlined),
              _howItWorksStep(3, 'Get Documents', 'Receive your legal documents', Icons.description_outlined),
            ]),
          ),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _howItWorksStep(int num, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)), child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900)),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
        ])),
        Icon(icon, color: AppColors.primary),
      ]),
    );
  }
}

class _WriterCard extends StatelessWidget {
  final UserModel writer;

  const _WriterCard({required this.writer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/writers/${writer.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            AvatarWidget(name: writer.name, imageUrl: writer.avatar, radius: 28),
            const SizedBox(height: 8),
            Text(writer.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (writer.districtName != null) ...[
              const SizedBox(height: 2),
              Text(writer.districtName!, style: const TextStyle(fontSize: 11, color: AppColors.gray500), textAlign: TextAlign.center),
            ],
            if (writer.averageRating != null) ...[
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                StarRatingWidget(rating: writer.averageRating!, size: 12),
                const SizedBox(width: 4),
                Text('(${writer.totalReviews ?? 0})', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
              ]),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/writers/${writer.id}'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 32), textStyle: const TextStyle(fontSize: 12)),
                child: const Text('View Profile'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
