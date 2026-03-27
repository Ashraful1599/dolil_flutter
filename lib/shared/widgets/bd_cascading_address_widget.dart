import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../models/bd_address_model.dart';

class BdCascadingAddressWidget extends StatefulWidget {
  final BdAddressSelection initialSelection;
  final void Function(BdAddressSelection) onChanged;

  const BdCascadingAddressWidget({
    super.key,
    required this.onChanged,
    this.initialSelection = const BdAddressSelection(),
  });

  @override
  State<BdCascadingAddressWidget> createState() => _BdCascadingAddressWidgetState();
}

class _BdCascadingAddressWidgetState extends State<BdCascadingAddressWidget> {
  BdAddressData? _data;
  late BdAddressSelection _sel;

  static const _addressTypes = [
    ('Union', 'ইউনিয়ন (Union)'),
    ('Municipality', 'পৌরসভা (Municipality)'),
    ('City Corporation', 'সিটি কর্পোরেশন (City Corporation)'),
  ];

  @override
  void initState() {
    super.initState();
    _sel = widget.initialSelection;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final raw = await rootBundle.loadString('assets/bangladesh_address_data.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (mounted) setState(() => _data = BdAddressData.fromJson(json));
    } catch (_) {}
  }

  void _update(BdAddressSelection next) {
    setState(() => _sel = next);
    widget.onChanged(next);
  }

  // Filtered lists
  List<BdDistrict> get _districts =>
      _data?.districts.where((d) => d.divisionId == _sel.divisionId).toList() ?? [];
  List<BdThana> get _thanas =>
      _data?.thanas.where((t) => t.districtId == _sel.districtId).toList() ?? [];
  List<BdUnion> get _unions =>
      _data?.unions.where((u) => u.thanaId == _sel.thanaId).toList() ?? [];
  List<BdMunicipality> get _municipalities =>
      _data?.municipalities.where((m) => m.districtId == _sel.districtId).toList() ?? [];
  List<BdCityCorporation> get _cityCorporations =>
      _data?.cityCorporations.where((c) => c.districtId == _sel.districtId).toList() ?? [];
  List<BdPostOffice> get _postOffices =>
      _data?.postOffices.where((p) => p.districtId == _sel.districtId).toList() ?? [];
  List<BdWard> get _wards => _data?.wards ?? [];

  // Display helpers
  String? _divisionName(String? id) => id == null ? null :
      _data?.divisions.where((d) => d.id == id).firstOrNull?.displayName;
  String? _districtName(String? id) => id == null ? null :
      _data?.districts.where((d) => d.id == id).firstOrNull?.displayName;
  String? _thanaName(String? id) => id == null ? null :
      _data?.thanas.where((t) => t.id == id).firstOrNull?.displayName;
  String? _unionName(String? id) => id == null ? null :
      _data?.unions.where((u) => u.id == id).firstOrNull?.displayName;
  String? _municipalityName(String? id) => id == null ? null :
      _data?.municipalities.where((m) => m.id == id).firstOrNull?.displayName;
  String? _cityCorporationName(String? id) => id == null ? null :
      _data?.cityCorporations.where((c) => c.id == id).firstOrNull?.displayName;
  String? _postOfficeName(String? id) => id == null ? null :
      _data?.postOffices.where((p) => p.id == id).firstOrNull?.displayName;
  String? _wardName(String? val) => val == null ? null :
      _data?.wards.where((w) => w.value == val).firstOrNull?.displayName;

  String? get _specificName {
    if (_sel.addressType == 'Municipality') return _municipalityName(_sel.municipalityId);
    if (_sel.addressType == 'City Corporation') return _cityCorporationName(_sel.cityCorporationId);
    return _unionName(_sel.unionId);
  }

  String get _specificLabel {
    if (_sel.addressType == 'Municipality') return 'পৌরসভা';
    if (_sel.addressType == 'City Corporation') return 'সিটি কর্পোরেশন';
    return 'ইউনিয়ন';
  }

  bool get _specificDisabled {
    if (_sel.addressType == 'Union') return _sel.thanaId == null;
    return _sel.districtId == null;
  }

  List get _specificItems {
    if (_sel.addressType == 'Municipality') return _municipalities;
    if (_sel.addressType == 'City Corporation') return _cityCorporations;
    return _unions;
  }

  Future<void> _showPicker<T>({
    required String title,
    required List<T> items,
    required String Function(T) getDisplay,
    required String Function(T) getId,
    required void Function(T) onSelect,
    String? searchHint,
  }) async {
    if (items.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _PickerSheet<T>(
        title: title,
        items: items,
        getDisplay: getDisplay,
        getId: getId,
        onSelect: onSelect,
        searchHint: searchHint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Row 1: Address Type | Division
      Row(children: [
        Expanded(child: _field(
          label: 'ঠিকানার ধরন',
          value: _addressTypes.where((t) => t.$1 == _sel.addressType).firstOrNull?.$2,
          hint: 'ধরন নির্বাচন করুন',
          onTap: () => _showPicker<(String, String)>(
            title: 'ঠিকানার ধরন',
            items: _addressTypes.toList(),
            getDisplay: (t) => t.$2,
            getId: (t) => t.$1,
            onSelect: (t) => _update(BdAddressSelection(
              addressType: t.$1,
            )),
          ),
        )),
        const SizedBox(width: 10),
        Expanded(child: _field(
          label: 'বিভাগ',
          value: _divisionName(_sel.divisionId),
          hint: 'বিভাগ নির্বাচন করুন',
          onTap: () => _showPicker<BdDivision>(
            title: 'বিভাগ নির্বাচন করুন',
            items: _data!.divisions,
            getDisplay: (d) => d.displayName,
            getId: (d) => d.id,
            onSelect: (d) => _update(_sel.copyWith(
              divisionId: d.id,
              districtId: null,
              thanaId: null,
              unionId: null,
              municipalityId: null,
              cityCorporationId: null,
              postOfficeId: null,
            )),
          ),
          onClear: _sel.divisionId == null ? null : () => _update(BdAddressSelection(
            addressType: _sel.addressType,
          )),
        )),
      ]),
      const SizedBox(height: 10),

      // Row 2: District | Thana
      Row(children: [
        Expanded(child: _field(
          label: 'জেলা',
          value: _districtName(_sel.districtId),
          hint: _sel.divisionId == null ? 'আগে বিভাগ নির্বাচন করুন' : 'জেলা নির্বাচন করুন',
          disabled: _sel.divisionId == null,
          onTap: () => _showPicker<BdDistrict>(
            title: 'জেলা নির্বাচন করুন',
            items: _districts,
            getDisplay: (d) => d.displayName,
            getId: (d) => d.id,
            onSelect: (d) => _update(_sel.copyWith(
              districtId: d.id,
              thanaId: null,
              unionId: null,
              municipalityId: null,
              cityCorporationId: null,
              postOfficeId: null,
            )),
            searchHint: 'জেলা খুঁজুন...',
          ),
          onClear: _sel.districtId == null ? null : () => _update(_sel.copyWith(
            districtId: null,
            thanaId: null,
            unionId: null,
            municipalityId: null,
            cityCorporationId: null,
            postOfficeId: null,
          )),
        )),
        const SizedBox(width: 10),
        Expanded(child: _field(
          label: 'থানা / উপজেলা',
          value: _thanaName(_sel.thanaId),
          hint: _sel.districtId == null ? 'আগে জেলা নির্বাচন করুন' : 'থানা নির্বাচন করুন',
          disabled: _sel.districtId == null,
          onTap: () => _showPicker<BdThana>(
            title: 'থানা / উপজেলা নির্বাচন করুন',
            items: _thanas,
            getDisplay: (t) => t.displayName,
            getId: (t) => t.id,
            onSelect: (t) => _update(_sel.copyWith(
              thanaId: t.id,
              unionId: null,
            )),
            searchHint: 'থানা খুঁজুন...',
          ),
          onClear: _sel.thanaId == null ? null : () => _update(_sel.copyWith(
            thanaId: null,
            unionId: null,
          )),
        )),
      ]),
      const SizedBox(height: 10),

      // Row 3: Union/Municipality/City Corp | Post Office
      Row(children: [
        Expanded(child: _field(
          label: _specificLabel,
          value: _specificName,
          hint: _specificDisabled ? 'আগে থানা নির্বাচন করুন' : 'নির্বাচন করুন',
          disabled: _specificDisabled,
          onTap: () => _showPicker(
            title: '$_specificLabel নির্বাচন করুন',
            items: _specificItems,
            getDisplay: (item) {
              if (item is BdUnion) return item.displayName;
              if (item is BdMunicipality) return item.displayName;
              if (item is BdCityCorporation) return item.displayName;
              return '';
            },
            getId: (item) {
              if (item is BdUnion) return item.id;
              if (item is BdMunicipality) return item.id;
              if (item is BdCityCorporation) return item.id;
              return '';
            },
            onSelect: (item) {
              if (_sel.addressType == 'Union' && item is BdUnion) {
                _update(_sel.copyWith(unionId: item.id, municipalityId: null, cityCorporationId: null));
              } else if (_sel.addressType == 'Municipality' && item is BdMunicipality) {
                _update(_sel.copyWith(municipalityId: item.id, unionId: null, cityCorporationId: null));
              } else if (_sel.addressType == 'City Corporation' && item is BdCityCorporation) {
                _update(_sel.copyWith(cityCorporationId: item.id, unionId: null, municipalityId: null));
              }
            },
            searchHint: 'খুঁজুন...',
          ),
        )),
        const SizedBox(width: 10),
        Expanded(child: _field(
          label: 'ডাকঘর',
          value: _postOfficeName(_sel.postOfficeId),
          hint: _sel.districtId == null ? 'আগে জেলা নির্বাচন করুন' : 'ডাকঘর নির্বাচন করুন',
          disabled: _sel.districtId == null,
          onTap: () => _showPicker<BdPostOffice>(
            title: 'ডাকঘর নির্বাচন করুন',
            items: _postOffices,
            getDisplay: (p) => p.displayName,
            getId: (p) => p.id,
            onSelect: (p) => _update(_sel.copyWith(postOfficeId: p.id)),
            searchHint: 'ডাকঘর খুঁজুন...',
          ),
          onClear: _sel.postOfficeId == null ? null : () => _update(_sel.copyWith(postOfficeId: null)),
        )),
      ]),
      const SizedBox(height: 10),

      // Row 4: Ward
      SizedBox(
        width: double.infinity,
        child: _field(
          label: 'ওয়ার্ড নং',
          value: _wardName(_sel.ward),
          hint: 'ওয়ার্ড নির্বাচন করুন',
          onTap: () => _showPicker<BdWard>(
            title: 'ওয়ার্ড নির্বাচন করুন',
            items: _wards,
            getDisplay: (w) => w.displayName,
            getId: (w) => w.value,
            onSelect: (w) => _update(_sel.copyWith(ward: w.value)),
          ),
          onClear: _sel.ward == null ? null : () => _update(_sel.copyWith(ward: null)),
        ),
      ),
    ]);
  }

  Widget _field({
    required String label,
    required String? value,
    required String hint,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool disabled = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray700)),
      const SizedBox(height: 4),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: disabled ? AppColors.gray100 : AppColors.white,
            border: Border.all(color: disabled ? AppColors.gray200 : AppColors.gray300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Expanded(child: Text(
              value ?? hint,
              style: TextStyle(
                fontSize: 13,
                color: value != null ? AppColors.gray900 : AppColors.gray400,
              ),
              overflow: TextOverflow.ellipsis,
            )),
            if (onClear != null && value != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: AppColors.gray400),
                ),
              )
            else if (!disabled)
              const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.gray400),
          ]),
        ),
      ),
    ]);
  }
}

// ── Searchable picker bottom sheet ─────────────────────────────────────────
class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) getDisplay;
  final String Function(T) getId;
  final void Function(T) onSelect;
  final String? searchHint;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.getDisplay,
    required this.getId,
    required this.onSelect,
    this.searchHint,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  List<T> get _filtered => _query.isEmpty
      ? widget.items
      : widget.items.where((item) =>
          widget.getDisplay(item).toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (widget.searchHint != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: widget.items.length > 10,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ],
          const Divider(),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No results', style: TextStyle(color: AppColors.gray400)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      return ListTile(
                        dense: true,
                        title: Text(widget.getDisplay(item), style: const TextStyle(fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelect(item);
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
