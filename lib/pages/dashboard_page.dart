import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/asset_record.dart';
import '../state/asset_state.dart';
import 'home_page.dart';

class DashboardPage extends StatefulWidget {
  final AssetState assetState;

  const DashboardPage({super.key, required this.assetState});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String _selectedDate;
  late AssetRecord _editingRecord;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.assetState.records.isEmpty) {
      final today = '${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}';
      _selectedDate = today;
      _editingRecord = AssetRecord(date: today);
    } else {
      _selectedDate = widget.assetState.records.first.date;
      _loadRecordForDate(_selectedDate);
    }
  }

  void _loadRecordForDate(String dateStr) {
    if (widget.assetState.records.isEmpty) {
      _editingRecord = AssetRecord(date: dateStr);
      _hasUnsavedChanges = false;
      return;
    }
    final original = widget.assetState.records.firstWhere(
      (r) => r.date == dateStr,
      orElse: () => AssetRecord(date: dateStr),
    );
    _editingRecord = original.copyWith();
    _hasUnsavedChanges = false;
  }

  void _addNewRecord() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1), // Header background
              onPrimary: Colors.white, // Header text
              onSurface: Color(0xFF1E293B), // Body text
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final newDateStr =
          '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
      widget.assetState.addDate(newDateStr);
      setState(() {
        _selectedDate = newDateStr;
        _loadRecordForDate(newDateStr);
      });
    }
  }

  void _onSave() {
    widget.assetState.saveRecord(_editingRecord);
    setState(() {
      _hasUnsavedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '已儲存當日資產狀況並更新主頁！',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateState(VoidCallback fn) {
    setState(() {
      fn();
      _hasUnsavedChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final record = _editingRecord;
    final totalStockPv = record.sinoStockPv + record.skisStockPv;
    final totalStockCost = record.sinoStockCost + record.skisStockCost;
    final totalBondPv = record.sinoBondPv + record.skisBondPv;
    final totalBondCost = record.sinoBondCost + record.skisBondCost;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black87,
                ),
                onPressed: () {
                  if (_hasUnsavedChanges) {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('尚未儲存'),
                        content: const Text('您有尚未儲存的變更，確定要返回主頁嗎？變更將會遺失。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HomePage(assetState: widget.assetState),
                                ),
                              );
                            },
                            child: const Text(
                              '確定返回',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomePage(assetState: widget.assetState),
                      ),
                    );
                  }
                },
              ),
              title: const Text(
                'Assets tracking Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.75),
              elevation: 0,
              actions: [
                Center(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDate,
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Color(0xFF6366F1),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                        items: widget.assetState.records.map((r) {
                          return DropdownMenuItem(
                            value: r.date,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                r.date +
                                    (_hasUnsavedChanges &&
                                            _selectedDate == r.date
                                        ? ' *'
                                        : ''),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != _selectedDate) {
                            if (_hasUnsavedChanges) {
                              // Ask confirm
                            } else {
                              setState(() {
                                _selectedDate = newValue;
                                _loadRecordForDate(newValue);
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      tooltip: '新增日期紀錄',
                      onPressed: _addNewRecord,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF), Color(0xFFF3E8FF)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            key: ValueKey(_selectedDate),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildAccountCard(
                                  '永豐帳戶',
                                  isSino: true,
                                  record: record,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildAccountCard(
                                  '新光帳戶',
                                  isSino: false,
                                  record: record,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildUsStockAccountCard('美股帳戶', record: record),
                              ),
                              const SizedBox(width: 24),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildAccountCard('永豐帳戶', isSino: true, record: record),
                        const SizedBox(height: 24),
                        _buildAccountCard(
                          '新光帳戶',
                          isSino: false,
                          record: record,
                        ),
                        const SizedBox(height: 24),
                        _buildUsStockAccountCard('美股帳戶', record: record),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(
                      Icons.savings_rounded,
                      color: Color(0xFFF59E0B),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '總現金',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildInputRow(
                      '總現金數額',
                      record.totalCash,
                      (val) => _updateState(() => record.totalCash = val),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(
                      Icons.pie_chart_rounded,
                      color: Color(0xFF6366F1),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '總資產分析',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildTotalTable(
                          totalStockPv,
                          totalStockCost,
                          totalBondPv,
                          totalBondCost,
                          record.usStockPv,
                          record.usStockCost,
                          record.totalCash,
                        ),
                        const SizedBox(height: 48),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 800) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildChart('資產現值比例', [
                                      totalStockPv,
                                      totalBondPv,
                                      record.totalCash,
                                    ]),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildChart('資產成本比例', [
                                      totalStockCost,
                                      totalBondCost,
                                      record.totalCash,
                                    ]),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildChart('資產現值比例', [
                                  totalStockPv,
                                  totalBondPv,
                                  record.totalCash,
                                ]),
                                const SizedBox(height: 40),
                                _buildChart('資產成本比例', [
                                  totalStockCost,
                                  totalBondCost,
                                  record.totalCash,
                                ]),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 儲存按鈕
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _hasUnsavedChanges ? _onSave : null,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      '儲存當日數據',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: _hasUnsavedChanges ? 8 : 0,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsStockAccountCard(
    String title, {
    required AssetRecord record,
  }) {
    return _buildModernCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Color(0xFF10B981),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildUsStockAssetSection(
              '股票',
              record: record,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsStockAssetSection(
    String label, {
    required AssetRecord record,
  }) {
    final pv = record.usStockPv;
    final cost = record.usStockCost;
    final pnl = pv - cost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.show_chart_rounded,
              size: 22,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputRow('現值', pv, (val) {
          _updateState(() {
            record.usStockPv = val;
          });
        }),
        const SizedBox(height: 12),
        _buildInputRow('付出成本', cost, (val) {
          _updateState(() {
            record.usStockCost = val;
          });
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Text(
                '損益',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pnl >= 0
                        ? [
                            const Color(0xFF10B981).withOpacity(0.12),
                            const Color(0xFF34D399).withOpacity(0.04),
                          ]
                        : [
                            const Color(0xFFEF4444).withOpacity(0.12),
                            const Color(0xFFF87171).withOpacity(0.04),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: pnl >= 0
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFEF4444).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  pnl >= 0
                      ? '+${pnl.toStringAsFixed(2)}'
                      : pnl.toStringAsFixed(2),
                  style: TextStyle(
                    color: pnl >= 0
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    String title, {
    required bool isSino,
    required AssetRecord record,
  }) {
    return _buildModernCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSino
                        ? const Color(0xFFEF4444).withOpacity(0.12)
                        : const Color(0xFF3B82F6).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSino
                        ? Icons.account_balance
                        : Icons.account_balance_wallet,
                    color: isSino
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAssetSection(
              '股票',
              isSino: isSino,
              isStock: true,
              record: record,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
            _buildAssetSection(
              '債券',
              isSino: isSino,
              isStock: false,
              record: record,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSection(
    String label, {
    required bool isSino,
    required bool isStock,
    required AssetRecord record,
  }) {
    final pv = isSino
        ? (isStock ? record.sinoStockPv : record.sinoBondPv)
        : (isStock ? record.skisStockPv : record.skisBondPv);
    final cost = isSino
        ? (isStock ? record.sinoStockCost : record.sinoBondCost)
        : (isStock ? record.skisStockCost : record.skisBondCost);
    final pnl = pv - cost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isStock ? Icons.show_chart_rounded : Icons.request_quote_rounded,
              size: 22,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInputRow('現值', pv, (val) {
          _updateState(() {
            if (isSino) {
              if (isStock)
                record.sinoStockPv = val;
              else
                record.sinoBondPv = val;
            } else {
              if (isStock)
                record.skisStockPv = val;
              else
                record.skisBondPv = val;
            }
          });
        }),
        const SizedBox(height: 12),
        _buildInputRow('付出成本', cost, (val) {
          _updateState(() {
            if (isSino) {
              if (isStock)
                record.sinoStockCost = val;
              else
                record.sinoBondCost = val;
            } else {
              if (isStock)
                record.skisStockCost = val;
              else
                record.skisBondCost = val;
            }
          });
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(
              width: 100,
              child: Text(
                '損益',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: pnl >= 0
                        ? [
                            const Color(0xFF10B981).withOpacity(0.12),
                            const Color(0xFF34D399).withOpacity(0.04),
                          ]
                        : [
                            const Color(0xFFEF4444).withOpacity(0.12),
                            const Color(0xFFF87171).withOpacity(0.04),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: pnl >= 0
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFEF4444).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  pnl >= 0
                      ? '+${pnl.toStringAsFixed(2)}'
                      : pnl.toStringAsFixed(2),
                  style: TextStyle(
                    color: pnl >= 0
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputRow(
    String label,
    double currentValue,
    Function(double) onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              fontSize: 15,
            ),
          ),
        ),
        Expanded(child: _buildInputField(currentValue, onChanged)),
      ],
    );
  }

  Widget _buildInputField(double currentValue, Function(double) onChanged) {
    return TextFormField(
      initialValue: currentValue == 0 ? '' : currentValue.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        hintText: '輸入數值',
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.grey.shade50,
        hoverColor: const Color(0xFFF8FAFC),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onChanged: (val) => onChanged(double.tryParse(val) ?? 0),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTotalTable(
    double totalStockPv,
    double totalStockCost,
    double totalBondPv,
    double totalBondCost,
    double totalUsStockPv,
    double totalUsStockCost,
    double totalCash,
  ) {
    return Table(
      border: const TableBorder(
        horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '股票',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '債券',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '美股',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '現金',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '總資產現值',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalStockPv.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalBondPv.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalUsStockPv.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalCash.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '總資產付出成本',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalStockCost.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalBondCost.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalUsStockCost.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                totalCash.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(String title, List<double> values) {
    final total = values.fold(0.0, (sum, item) => sum + item);
    final percentages = total > 0 
        ? values.map((v) => (v / total) * 100).toList() 
        : [0.0, 0.0, 0.0];

    final maxVal = percentages.reduce((a, b) => a > b ? a : b);
    final upperLimit = maxVal > 0 ? ((maxVal / 10).ceil() * 10).toDouble() + 10 : 100.0;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: upperLimit > 100 ? 100 : upperLimit,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)}%',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    getTitlesWidget: (value, meta) {
                      const titles = ['股票', '債券', '現金'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: Text(
                          titles[value.toInt()],
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, percentages[0], const Color(0xFF3B82F6)),
                _buildBarGroup(1, percentages[1], const Color(0xFFA855F7)),
                _buildBarGroup(2, percentages[2], const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 48,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ],
    );
  }
}
