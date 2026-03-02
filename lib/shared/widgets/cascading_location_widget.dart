import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../../core/theme/app_colors.dart';

class CascadingLocationWidget extends StatefulWidget {
  final List<DivisionModel> divisions;
  final int? initialDivisionId;
  final int? initialDistrictId;
  final int? initialUpazilaId;
  final Future<List<DistrictModel>> Function(int) loadDistricts;
  final Future<List<UpazilaModel>> Function(int) loadUpazilas;
  final void Function(int? divisionId, int? districtId, int? upazilaId) onChanged;

  const CascadingLocationWidget({
    super.key,
    required this.divisions,
    this.initialDivisionId,
    this.initialDistrictId,
    this.initialUpazilaId,
    required this.loadDistricts,
    required this.loadUpazilas,
    required this.onChanged,
  });

  @override
  State<CascadingLocationWidget> createState() => _CascadingLocationWidgetState();
}

class _CascadingLocationWidgetState extends State<CascadingLocationWidget> {
  int? _divId, _distId, _upaId;
  String? _divName, _distName, _upaName;
  List<DistrictModel> _districts = [];
  List<UpazilaModel> _upazilas = [];
  bool _loadingDist = false, _loadingUpa = false;

  @override
  void initState() {
    super.initState();
    _divId = widget.initialDivisionId;
    _distId = widget.initialDistrictId;
    _upaId = widget.initialUpazilaId;
    // Set display names from initial values
    if (_divId != null && widget.divisions.isNotEmpty) {
      final div = widget.divisions.where((d) => d.id == _divId).toList();
      if (div.isNotEmpty) _divName = div.first.name;
    }
    if (_divId != null) _fetchDistricts(_divId!, preserveDistrictId: _distId);
  }

  Future<void> _fetchDistricts(int id, {int? preserveDistrictId}) async {
    setState(() {
      _loadingDist = true;
      _districts = [];
      if (preserveDistrictId == null) {
        _distId = null;
        _distName = null;
      }
      _upazilas = [];
      _upaId = null;
      _upaName = null;
    });
    try {
      final list = await widget.loadDistricts(id);
      if (mounted) {
        setState(() {
          _districts = list;
          // Restore pre-selected district if preserving
          if (preserveDistrictId != null) {
            final match = list.where((d) => d.id == preserveDistrictId).isNotEmpty;
            if (match) {
              _distId = preserveDistrictId;
              _distName = list.firstWhere((d) => d.id == preserveDistrictId).name;
            }
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingDist = false);
    }
  }

  Future<void> _fetchUpazilas(int id) async {
    setState(() {
      _loadingUpa = true;
      _upazilas = [];
      _upaId = null;
      _upaName = null;
    });
    try {
      final list = await widget.loadUpazilas(id);
      if (mounted) setState(() => _upazilas = list);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingUpa = false);
    }
  }

  Future<void> _showPicker<T>({
    required BuildContext ctx,
    required String label,
    required List<T> items,
    required int Function(T) getId,
    required String Function(T) getName,
    required void Function(int id, String name) onSelect,
  }) async {
    if (items.isEmpty) return;
    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select $label',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return ListTile(
                      title: Text(getName(item)),
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        onSelect(getId(item), getName(item));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildField(
        context: context,
        label: 'Division',
        selectedName: _divName,
        hint: widget.divisions.isEmpty ? 'Loading...' : 'Select Division',
        loading: widget.divisions.isEmpty,
        hasValue: _divId != null,
        onTap: () => _showPicker<DivisionModel>(
          ctx: context,
          label: 'Division',
          items: widget.divisions,
          getId: (d) => d.id,
          getName: (d) => d.name,
          onSelect: (id, name) {
            setState(() {
              _divId = id;
              _divName = name;
              _distId = null;
              _distName = null;
              _upaId = null;
              _upaName = null;
              _districts = [];
              _upazilas = [];
            });
            _fetchDistricts(id);
            widget.onChanged(id, null, null);
          },
        ),
        onClear: _divId == null
            ? null
            : () {
                setState(() {
                  _divId = null;
                  _divName = null;
                  _distId = null;
                  _distName = null;
                  _upaId = null;
                  _upaName = null;
                  _districts = [];
                  _upazilas = [];
                });
                widget.onChanged(null, null, null);
              },
      ),
      const SizedBox(height: 12),

      _buildField(
        context: context,
        label: 'District',
        selectedName: _distName,
        hint: _divId == null ? 'Select division first' : (_loadingDist ? 'Loading...' : 'Select District'),
        loading: _loadingDist,
        hasValue: _distId != null,
        onTap: () => _showPicker<DistrictModel>(
          ctx: context,
          label: 'District',
          items: _districts,
          getId: (d) => d.id,
          getName: (d) => d.name,
          onSelect: (id, name) {
            setState(() {
              _distId = id;
              _distName = name;
              _upaId = null;
              _upaName = null;
              _upazilas = [];
            });
            _fetchUpazilas(id);
            widget.onChanged(_divId, id, null);
          },
        ),
        onClear: _distId == null
            ? null
            : () {
                setState(() {
                  _distId = null;
                  _distName = null;
                  _upaId = null;
                  _upaName = null;
                  _upazilas = [];
                });
                widget.onChanged(_divId, null, null);
              },
      ),
      const SizedBox(height: 12),

      _buildField(
        context: context,
        label: 'Upazila',
        selectedName: _upaName,
        hint: _distId == null ? 'Select district first' : (_loadingUpa ? 'Loading...' : 'Select Upazila'),
        loading: _loadingUpa,
        hasValue: _upaId != null,
        onTap: () => _showPicker<UpazilaModel>(
          ctx: context,
          label: 'Upazila',
          items: _upazilas,
          getId: (u) => u.id,
          getName: (u) => u.name,
          onSelect: (id, name) {
            setState(() {
              _upaId = id;
              _upaName = name;
            });
            widget.onChanged(_divId, _distId, id);
          },
        ),
        onClear: _upaId == null
            ? null
            : () {
                setState(() {
                  _upaId = null;
                  _upaName = null;
                });
                widget.onChanged(_divId, _distId, null);
              },
      ),
    ]);
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required String? selectedName,
    required String hint,
    required bool loading,
    required bool hasValue,
    required VoidCallback onTap,
    required VoidCallback? onClear,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.gray700,
        ),
      ),
      const SizedBox(height: 4),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: loading ? null : onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.gray200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Row(children: [
                  Expanded(
                    child: Text(
                      selectedName ?? hint,
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedName != null
                            ? AppColors.gray900
                            : AppColors.gray400,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onClear,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 16, color: AppColors.gray400),
                      ),
                    )
                  else
                    const Icon(Icons.arrow_drop_down, color: AppColors.gray400),
                ]),
        ),
      ),
    ]);
  }
}
