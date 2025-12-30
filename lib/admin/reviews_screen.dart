import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/review_model.dart';
import '../models/transaction_model.dart';
import '../services/worker_auth_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _filterRating = 'All';
  final FirestoreService _firestoreService = FirestoreService();

  List<Review> _filterReviews(List<Review> reviews) {
    if (_filterRating == 'All') return reviews;

    if (_filterRating == 'Poor (1-2)') {
      return reviews.where((r) => r.rating <= 2).toList();
    } else if (_filterRating == 'Average (3)') {
      return reviews.where((r) => r.rating == 3).toList();
    } else if (_filterRating == 'Good (4-5)') {
      return reviews.where((r) => r.rating >= 4).toList();
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Insights feature coming soon with real-time specific metrics.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Review>>(
        stream: _firestoreService.getReviewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final allReviews = snapshot.data ?? [];
          final filteredReviews = _filterReviews(allReviews);

          return Column(
            children: [
              _buildSummaryCards(allReviews),
              _buildFilterChips(),
              Expanded(
                child: filteredReviews.isEmpty
                    ? const Center(
                        child: Text(
                          'No reviews found',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) =>
                            _buildReviewCard(filteredReviews[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Review> reviews) {
    int totalReviews = reviews.length;
    int poorReviews = reviews.where((r) => r.rating <= 2).length;
    int goodReviews = reviews.where((r) => r.rating >= 4).length;
    double avgRating = totalReviews > 0
        ? reviews.fold(0.0, (sum, r) => sum + r.rating) / totalReviews
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSmallStatCard(
              'Avg Rating',
              avgRating.toStringAsFixed(1),
              Icons.star,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
              'Good Reviews',
              '$goodReviews',
              Icons.thumb_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSmallStatCard(
              'Poor Reviews',
              '$poorReviews',
              Icons.thumb_down,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Poor (1-2)', 'Average (3)', 'Good (4-5)'].map((
            filter,
          ) {
            final isSelected = _filterRating == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filterRating = filter);
                },
                selectedColor: const Color(0xFF005DFF),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final rating = review.rating.toInt();
    final isPoorRating = rating <= 2;
    final status = review.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPoorRating
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRatingColor(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getRatingIcon(rating),
              color: _getRatingColor(rating),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review.workerName.isNotEmpty &&
                              review.workerName != 'Unknown Worker'
                          ? '${review.serviceName} • ${review.workerName}'
                          : review.serviceName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildRatingBadge(rating),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Published'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status == 'Published'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Review:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        backgroundImage:
                            review.workerId.isNotEmpty &&
                                WorkerAuthService()
                                        .getWorkerById(review.workerId)
                                        ?.profilePhotoUrl !=
                                    null
                            ? NetworkImage(
                                WorkerAuthService()
                                    .getWorkerById(review.workerId)!
                                    .profilePhotoUrl!,
                              )
                            : null,
                        child:
                            review.workerId.isEmpty ||
                                WorkerAuthService()
                                        .getWorkerById(review.workerId)
                                        ?.profilePhotoUrl ==
                                    null
                            ? const Icon(
                                Icons.person,
                                size: 8,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Worker: ${review.workerName} (${review.workerId})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Service ID: ${review.serviceId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (status == 'Pending Action') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _markAsResolved(review),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark Resolved'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showDeductionDialog(review),
                    icon: const Icon(Icons.remove_circle, size: 18),
                    label: const Text('Deduct Credit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Review Published',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(int rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRatingColor(rating).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 16, color: _getRatingColor(rating)),
          const SizedBox(width: 4),
          Text(
            '$rating/5',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.orange;
    return Colors.red;
  }

  IconData _getRatingIcon(int rating) {
    if (rating >= 4) return Icons.thumb_up;
    if (rating == 3) return Icons.sentiment_neutral;
    return Icons.thumb_down;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _markAsResolved(Review review) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: Text(
          'Mark this review from ${review.customerName} as resolved?\n\nThis will publish the review without any penalty.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final updatedReview = review.copyWith(status: 'Resolved');
              await _firestoreService.updateReview(updatedReview);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Review marked as resolved for ${review.workerName}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  void _showDeductionDialog(Review review) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Deduct Worker Credit'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      backgroundImage:
                          review.workerId.isNotEmpty &&
                              WorkerAuthService()
                                      .getWorkerById(review.workerId)
                                      ?.profilePhotoUrl !=
                                  null
                          ? NetworkImage(
                              WorkerAuthService()
                                  .getWorkerById(review.workerId)!
                                  .profilePhotoUrl!,
                            )
                          : null,
                      child:
                          review.workerId.isEmpty ||
                              WorkerAuthService()
                                      .getWorkerById(review.workerId)
                                      ?.profilePhotoUrl ==
                                  null
                          ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.red,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worker: ${review.workerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Worker ID: ${review.workerId}'),
                          Text('Service: ${review.serviceName}'),
                          Text('Rating: ${review.rating}/5'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deduction Amount (SAR)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: 'Enter amount',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for Deduction',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  hintText: 'Explain the reason',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will deduct credit from the worker\'s account immediately',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              amountController.dispose();
              reasonController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final reason = reasonController.text.trim();

              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final worker = WorkerAuthService().getWorkerById(review.workerId);
              if (worker == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Worker not found'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newBalance = worker.creditBalance - amount;

              final success = WorkerAuthService().updateWorkerCredit(
                worker.phone,
                newBalance,
              );

              if (success) {
                try {
                  final transaction = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    workerId: review.workerId,
                    workerName: review.workerName,
                    type: TransactionType.creditDeduction,
                    amount: amount,
                    balanceBefore: worker.creditBalance,
                    balanceAfter: newBalance,
                    serviceRequestId: review.serviceId,
                    description: 'Penalty for ${review.serviceName}: $reason',
                    createdAt: DateTime.now(),
                  );

                  await _firestoreService.addTransaction(transaction);
                } catch (e) {
                  debugPrint('❌ Failed to log transaction: $e');
                }

                final updatedReview = review.copyWith(status: 'Resolved');
                await _firestoreService.updateReview(updatedReview);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✅ Credit deducted from ${review.workerName}'),
                        Text('Amount: SAR ${amount.toStringAsFixed(2)}'),
                        Text('Reason: $reason'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update worker credit'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              amountController.dispose();
              reasonController.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deduct Credit'),
          ),
        ],
      ),
    );
  }
}
