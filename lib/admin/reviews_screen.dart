import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _filterRating = 'All';

  final List<Map<String, dynamic>> _reviews = [
    {
      'id': 'REV001',
      'customer': 'Ahmed Ali',
      'worker': 'Hassan Mohammed',
      'workerId': 'W001',
      'service': 'AC Repair',
      'serviceId': 'SRV001',
      'rating': 5,
      'comment': 'Excellent service! Very professional and completed on time.',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Published',
    },
    {
      'id': 'REV002',
      'customer': 'Fatima Khan',
      'worker': 'Abdullah Khalid',
      'workerId': 'W002',
      'service': 'Plumbing Service',
      'serviceId': 'SRV002',
      'rating': 2,
      'comment': 'Service was not completed properly. Had to call again for fixes.',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Pending Action',
    },
    {
      'id': 'REV003',
      'customer': 'Mohammed Saleh',
      'worker': 'Hassan Mohammed',
      'workerId': 'W001',
      'service': 'Electrical Work',
      'serviceId': 'SRV003',
      'rating': 4,
      'comment': 'Good service overall, but took longer than expected.',
      'date': DateTime.now().subtract(const Duration(hours: 8)),
      'status': 'Published',
    },
    {
      'id': 'REV004',
      'customer': 'Sara Ahmed',
      'worker': 'Abdullah Khalid',
      'workerId': 'W002',
      'service': 'Carpentry',
      'serviceId': 'SRV004',
      'rating': 1,
      'comment': 'Poor quality work. Not satisfied at all.',
      'date': DateTime.now().subtract(const Duration(hours: 12)),
      'status': 'Pending Action',
    },
    {
      'id': 'REV005',
      'customer': 'Khalid Hassan',
      'worker': 'Hassan Mohammed',
      'workerId': 'W001',
      'service': 'Painting Service',
      'serviceId': 'SRV005',
      'rating': 5,
      'comment': 'Amazing work! Very detailed and clean finish.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Published',
    },
  ];

  List<Map<String, dynamic>> get _filteredReviews {
    if (_filterRating == 'All') return _reviews;

    if (_filterRating == 'Poor (1-2)') {
      return _reviews.where((r) => r['rating'] <= 2).toList();
    } else if (_filterRating == 'Average (3)') {
      return _reviews.where((r) => r['rating'] == 3).toList();
    } else if (_filterRating == 'Good (4-5)') {
      return _reviews.where((r) => r['rating'] >= 4).toList();
    }

    return _reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        backgroundColor: const Color(0xFF6B5B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => _showReviewInsights(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredReviews.length,
              itemBuilder: (context, index) => _buildReviewCard(_filteredReviews[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    int totalReviews = _reviews.length;
    int poorReviews = _reviews.where((r) => r['rating'] <= 2).length;
    int goodReviews = _reviews.where((r) => r['rating'] >= 4).length;
    double avgRating = _reviews.fold(0, (sum, r) => sum + (r['rating'] as int)) / totalReviews;

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

  Widget _buildSmallStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          children: [
            'All',
            'Poor (1-2)',
            'Average (3)',
            'Good (4-5)',
          ].map((filter) {
            final isSelected = _filterRating == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filterRating = filter);
                },
                selectedColor: const Color(0xFF6B5B9A),
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

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as int;
    final isPoorRating = rating <= 2;
    final status = review['status'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPoorRating ? Colors.red.withOpacity(0.3) : Colors.transparent,
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
              color: _getRatingColor(rating).withOpacity(0.1),
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
                      review['customer'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${review['service']} • ${review['worker']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Published'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status == 'Published' ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(review['date']),
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
                    review['comment'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Worker: ${review['worker']} (${review['workerId']})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.receipt, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Service ID: ${review['serviceId']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
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
        color: _getRatingColor(rating).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getRatingColor(rating).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: _getRatingColor(rating),
          ),
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

  void _markAsResolved(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: Text(
          'Mark this review from ${review['customer']} as resolved?\n\nThis will publish the review without any penalty.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                review['status'] = 'Published';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Review marked as resolved for ${review['worker']}'),
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

  void _showDeductionDialog(Map<String, dynamic> review) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Worker: ${review['worker']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Worker ID: ${review['workerId']}'),
                    Text('Service: ${review['service']}'),
                    Text('Rating: ${review['rating']}/5'),
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
                  color: Colors.orange.withOpacity(0.1),
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
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
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

              Navigator.pop(context);
              setState(() {
                review['status'] = 'Published';
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✅ Credit deducted from ${review['worker']}'),
                      Text('Amount: SAR ${amount.toStringAsFixed(2)}'),
                      Text('Reason: $reason'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );

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

  void _showReviewInsights() {
    final totalReviews = _reviews.length;
    final avgRating = _reviews.fold(0, (sum, r) => sum + (r['rating'] as int)) / totalReviews;
    final rating5 = _reviews.where((r) => r['rating'] == 5).length;
    final rating4 = _reviews.where((r) => r['rating'] == 4).length;
    final rating3 = _reviews.where((r) => r['rating'] == 3).length;
    final rating2 = _reviews.where((r) => r['rating'] == 2).length;
    final rating1 = _reviews.where((r) => r['rating'] == 1).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Insights'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B5B9A), Color(0xFF8B7AB8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Average Rating',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                      ],
                    ),
                    Text(
                      'Based on $totalReviews reviews',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRatingBar('5 Stars', rating5, totalReviews, Colors.green),
              _buildRatingBar('4 Stars', rating4, totalReviews, Colors.lightGreen),
              _buildRatingBar('3 Stars', rating3, totalReviews, Colors.orange),
              _buildRatingBar('2 Stars', rating2, totalReviews, Colors.deepOrange),
              _buildRatingBar('1 Star', rating1, totalReviews, Colors.red),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '$count (${percentage.toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}