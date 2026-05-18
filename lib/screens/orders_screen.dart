import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/colors.dart';
import '../core/data/app_database.dart';
import 'cancel_order_screen.dart';
import 'leave_review_screen.dart';
import 'menu_screen.dart';
import 'main_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _tab = 0; // 0=Active  1=Completed  2=Cancelled

  void _refresh() => setState(() {});

  List<AppOrder> get _currentOrders {
    switch (_tab) {
      case 1:
        return AppDB.completedOrders;
      case 2:
        return AppDB.cancelledOrders;
      default:
        return AppDB.activeOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────
          Container(
            color: kBrown,
            padding: EdgeInsets.only(
              top: topPad + 14,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      final state = context
                          .findAncestorStateOfType<MainScreenState>();
                      if (state != null) {
                        state.switchTab(kTabHome);
                      } else {
                        Navigator.maybePop(context);
                      }
                    },
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const Text(
                  'My Orders',
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ── Tab row ──────────────────────────────────
          Container(
            color: kBg,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                _Tab(
                  label: 'Active',
                  isActive: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 8),
                _Tab(
                  label: 'Completed',
                  isActive: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                const SizedBox(width: 8),
                _Tab(
                  label: 'Cancelled',
                  isActive: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),

          // ── Orders list / empty state ─────────────────
          Expanded(
            child: _currentOrders.isEmpty
                ? _EmptyState(tab: _tab)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _currentOrders.length,
                    itemBuilder: (_, i) => _OrderCard(
                      order: _currentOrders[i],
                      onRefresh: _refresh,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Tab pill ──────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _Tab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? kBrown : Colors.black26,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'LeagueSpartan',
            color: isActive ? Colors.white : kBrown.withOpacity(0.6),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final int tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final msgs = [
      "You don't have any\nactive orders at this\ntime",
      "You don't have any\ncompleted orders yet",
      "You don't have any\ncancelled orders",
    ];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/order.png',
            width: 110,
            height: 110,
            color: kBrown.withOpacity(0.15),
            errorBuilder: (ctx, e, s) => Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: kBrown.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            msgs[tab],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final VoidCallback onRefresh;
  const _OrderCard({required this.order, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM, hh:mm a').format(order.date);
    final firstItem = order.items.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              firstItem.product.image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) => Container(
                width: 64,
                height: 64,
                color: kInputBg,
                child: const Icon(Icons.coffee, color: kBrownLight, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info + action buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstItem.product.name,
                  style: const TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'LeagueSpartan',
                    color: kBrown.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),

                // ── "Order delivered" status line ────────
                if (order.status == OrderStatus.completed) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: kBrown.withOpacity(0.5),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Order delivered',
                        style: TextStyle(
                          fontFamily: 'LeagueSpartan',
                          color: kBrown.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),

                // ── Action buttons row ────────────────────
                if (order.status == OrderStatus.active)
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CancelOrderScreen(
                            order: order,
                            onCancelled: onRefresh,
                          ),
                        ),
                      );
                    },
                    child: _ActionBtn(label: 'Cancel Order', filled: true),
                  ),

                if (order.status == OrderStatus.completed)
                  Row(
                    children: [
                      // Leave a review → LeaveReviewScreen
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeaveReviewScreen(order: order),
                            ),
                          );
                          onRefresh();
                        },
                        child: _ActionBtn(
                          label: 'Leave a review',
                          filled: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Order Again → MenuScreen
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MenuScreen()),
                        ),
                        child: _ActionBtn(label: 'Order Again', filled: false),
                      ),
                    ],
                  ),

                if (order.status == OrderStatus.cancelled &&
                    order.cancelReason != null)
                  Text(
                    order.cancelReason!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      color: Colors.red,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Price
          Text(
            order.formattedTotal,
            style: const TextStyle(
              fontFamily: 'LeagueSpartan',
              color: kBrown,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small action button ───────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final bool filled; // true = dark brown, false = outline

  const _ActionBtn({required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? kBrown : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: filled ? kBrown : kBrown.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'LeagueSpartan',
          color: filled ? Colors.white : kBrown,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
