import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../state/asset_state.dart';
import '../models/asset_record.dart';
import 'dashboard_page.dart';

class HomePage extends StatelessWidget {
  final AssetState assetState;

  const HomePage({super.key, required this.assetState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.show_chart_rounded,
                      size: 40,
                      color: Color(0xFF1E293B),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Assets trend',
                      style: GoogleFonts.notoSansTc(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 48),
                Expanded(
                  child: AnimatedBuilder(
                    animation: assetState,
                    builder: (context, _) =>
                        _buildLineChartArea(assetState.records),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, anim, secAnim) =>
                            DashboardPage(assetState: assetState),
                        transitionsBuilder: (context, anim, secAnim, child) {
                          return FadeTransition(opacity: anim, child: child);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 56,
                      vertical: 24,
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '進入面板',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartArea(List<AssetRecord> records) {
    if (records.isEmpty)
      return const Center(
        child: Text('暫無資料', style: TextStyle(color: Colors.black54)),
      );

    final chronRecords = records.reversed.toList();
    List<FlSpot> spotsTotal = [];
    List<FlSpot> spotsStock = [];
    List<FlSpot> spotsBond = [];
    List<FlSpot> spotsCash = [];

    double minY = double.infinity;
    double maxY = -double.infinity;

    for (int i = 0; i < chronRecords.length; i++) {
      final r = chronRecords[i];
      final totalPv = r.totalPv;
      final stockPv = r.sinoStockPv + r.skisStockPv;
      final bondPv = r.sinoBondPv + r.skisBondPv;
      final cashPv = r.totalCash;

      spotsTotal.add(FlSpot(i.toDouble(), totalPv));
      spotsStock.add(FlSpot(i.toDouble(), stockPv));
      spotsBond.add(FlSpot(i.toDouble(), bondPv));
      spotsCash.add(FlSpot(i.toDouble(), cashPv));

      final maxVal = [
        totalPv,
        stockPv,
        bondPv,
        cashPv,
      ].reduce((a, b) => a > b ? a : b);
      final minVal = [
        totalPv,
        stockPv,
        bondPv,
        cashPv,
      ].reduce((a, b) => a < b ? a : b);

      if (maxVal > maxY) maxY = maxVal;
      if (minVal < minY) minY = minVal;
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == -double.infinity) maxY = 100;

    if (minY == maxY) {
      minY -= 10;
      maxY += 10;
    } else {
      final padding = (maxY - minY) * 0.2;
      minY -= padding;
      maxY += padding;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('總資產', const Color(0xFF6366F1)),
              const SizedBox(width: 16),
              _buildLegend('股票', const Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              _buildLegend('債券', const Color(0xFFA855F7)),
              const SizedBox(width: 16),
              _buildLegend('現金', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY < 0 ? 0 : minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < chronRecords.length) {
                          final dateStr = chronRecords[idx].date.substring(
                            5,
                          ); // e.g. "03/26"
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              dateStr,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
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
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _buildLineChartBarData(
                    spotsTotal,
                    const Color(0xFF6366F1),
                    true,
                  ),
                  _buildLineChartBarData(
                    spotsStock,
                    const Color(0xFF3B82F6),
                    false,
                  ),
                  _buildLineChartBarData(
                    spotsBond,
                    const Color(0xFFA855F7),
                    false,
                  ),
                  _buildLineChartBarData(
                    spotsCash,
                    const Color(0xFFF59E0B),
                    false,
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          spot.y.toStringAsFixed(0),
                          TextStyle(
                            color: [
                              const Color(0xFF6366F1),
                              const Color(0xFF3B82F6),
                              const Color(0xFFA855F7),
                              const Color(0xFFF59E0B),
                            ][spot.barIndex],
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(
    List<FlSpot> spots,
    Color color,
    bool isPrimary,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: isPrimary ? 4 : 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: isPrimary ? 5 : 4,
            color: Colors.white,
            strokeWidth: isPrimary ? 3 : 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: isPrimary,
        gradient: isPrimary
            ? LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
