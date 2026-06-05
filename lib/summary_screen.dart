import 'package:flutter/material.dart';
import 'dart:math';
import 'data_model.dart';
import 'mock_data.dart';

class SpendSummaryScreen extends StatefulWidget {
  const SpendSummaryScreen({super.key});

  @override
  State<SpendSummaryScreen> createState() => _SpendSummaryScreenState();
}

class _SpendSummaryScreenState extends State<SpendSummaryScreen>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // small delay so the screen settles first
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          _buildBgBlobs(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _topBar()),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _summaryCard(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _categoriesSection()),
                SliverToBoxAdapter(child: _txHeader()),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _txTile(transactions[i], i),
                    childCount: transactions.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
          _fab(),
        ],
      ),
    );
  }

  // subtle background gradient blobs
  Widget _buildBgBlobs() {
    return Positioned.fill(
      child: CustomPaint(painter: _BgPainter()),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JUNE 2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Spend Summary',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7C6AF7), Color(0xFFB06CF4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C6AF7).withOpacity(0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1C1040),
              Color(0xFF2A1660),
              Color(0xFF1A0E3E),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF7C6AF7).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6AF7).withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // label + % change badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Spent',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                _changeBadge(),
              ],
            ),
            const SizedBox(height: 10),

            // amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  '42,805',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '.50',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _spendProgressBar(),
            const SizedBox(height: 14),

            // bottom stats row
            Row(
              children: [
                _miniStat('Budget', '₹50,000', const Color(0xFF7C6AF7)),
                const SizedBox(width: 24),
                _miniStat('Left', '₹7,195', const Color(0xFF6BCB77)),
                const SizedBox(width: 24),
                _miniStat('Savings', '14.4%', const Color(0xFF4ECDC4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _changeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withOpacity(0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.arrow_upward_rounded, size: 11, color: Color(0xFFFF6B6B)),
          SizedBox(width: 3),
          Text(
            '12.4% vs last month',
            style: TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _spendProgressBar() {
    const double progress = 0.856;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(
            height: 7,
            color: Colors.white.withOpacity(0.07),
          ),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C6AF7), Color(0xFFFF6B6B)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.38),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _categoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: open categories page
                },
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: Color(0xFF7C6AF7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (ctx, i) => _categoryChip(categories[i], i),
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(Category cat, int index) {
    final isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? cat.color.withOpacity(0.15)
              : const Color(0xFF141420),
          border: Border.all(
            color: isSelected
                ? cat.color.withOpacity(0.55)
                : Colors.white.withOpacity(0.06),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: cat.color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 5),
            Text(
              cat.name,
              style: TextStyle(
                color: isSelected
                    ? cat.color
                    : Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _txHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C6AF7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${transactions.length} items',
              style: const TextStyle(
                color: Color(0xFF7C6AF7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _txTile(Transaction tx, int index) {
    final delay = min(index, 10) * 40;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + delay),
      curve: Curves.easeOut,
      builder: (ctx, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - val)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF111118),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            // icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tx.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tx.color.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(tx.emoji, style: const TextStyle(fontSize: 19)),
              ),
            ),
            const SizedBox(width: 12),

            // merchant + category tag
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.merchant,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tx.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          tx.category,
                          style: TextStyle(
                            color: tx.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tx.date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // amount
            Text(
              '- ₹${tx.amount.abs().toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab() {
    return Positioned(
      bottom: 32,
      right: 24,
      child: GestureDetector(
        onTap: _showAddExpenseSheet,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9B84FF), Color(0xFF7C6AF7)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6AF7).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showAddExpenseSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add expense — coming soon'),
        backgroundColor: const Color(0xFF7C6AF7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;

    p.color = const Color(0xFF7C6AF7).withOpacity(0.04);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.1), 170, p);

    p.color = const Color(0xFFFF6B6B).withOpacity(0.03);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.35), 130, p);

    p.color = const Color(0xFF4ECDC4).withOpacity(0.025);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.7), 110, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}