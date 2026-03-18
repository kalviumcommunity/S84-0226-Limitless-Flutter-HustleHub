import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment_model.dart';
import '../providers/payments_provider.dart';
import '../utils/constants.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedFilter = 0;
  final List<String> filters = ['All', 'Pending', 'Completed', 'Overdue'];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 1,
        title: const Text('Payments'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPaymentDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(isMobile),
                SizedBox(height: AppSpacing.lg),
                _buildFilterChips(),
                SizedBox(height: AppSpacing.lg),
                _buildPaymentsList(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isMobile) {
    return Consumer<PaymentsProvider>(
      builder: (context, paymentsProvider, child) {
        final totalRevenue = paymentsProvider.getTotalRevenue();
        final totalPending = paymentsProvider.getTotalPending();
        final overdueCount = paymentsProvider.getOverduePayments().length;

        return GridView.count(
          crossAxisCount: isMobile ? 1 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: isMobile ? 2 : 1.2,
          children: [
            _buildStatCard(
              title: 'Total Revenue',
              value: '\$${totalRevenue.toStringAsFixed(2)}',
              icon: Icons.trending_up_outlined,
              color: AppColors.successColor,
            ),
            _buildStatCard(
              title: 'Pending Amount',
              value: '\$${totalPending.toStringAsFixed(2)}',
              icon: Icons.schedule_outlined,
              color: AppColors.accentColor,
            ),
            _buildStatCard(
              title: 'Overdue',
              value: '$overdueCount Payments',
              icon: Icons.warning_outlined,
              color: AppColors.errorColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          filters.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilterChip(
              label: Text(filters[index]),
              selected: _selectedFilter == index,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsList(bool isMobile) {
    return Consumer<PaymentsProvider>(
      builder: (context, paymentsProvider, child) {
        if (paymentsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Payment> filteredPayments = _getFilteredPayments(paymentsProvider);

        if (filteredPayments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: AppColors.textSecondaryColor,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No payments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = filteredPayments[index];
            return _buildPaymentCard(context, payment, isMobile);
          },
        );
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Payment payment,
    bool isMobile,
  ) {
    final statusColor = _getStatusColor(payment.status);
    final statusIcon = _getStatusIcon(payment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      if (payment.invoiceNumber != null)
                        Text(
                          'Invoice: ${payment.invoiceNumber}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondaryColor),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Edit'),
                      onTap: () => _showEditPaymentDialog(context, payment),
                    ),
                    if (payment.status != PaymentStatus.completed)
                      PopupMenuItem(
                        child: const Text('Mark as Paid'),
                        onTap: () => _markAsPaid(context, payment.id),
                      ),
                    PopupMenuItem(
                      child: const Text('Delete'),
                      onTap: () => _deletePayment(context, payment.id),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${payment.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(payment.status.toString().split('.').last),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: statusColor),
                  avatar: Icon(statusIcon, color: statusColor, size: 16),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondaryColor,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Due: ${payment.dueDate.toString().split(' ')[0]}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondaryColor),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 16,
                            color: AppColors.textSecondaryColor,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            payment.method.toString().split('.').last,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (payment.isOverdue || payment.isDueToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      payment.isOverdue ? 'Overdue' : 'Due Today',
                      style: TextStyle(
                        color: AppColors.errorColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final invoiceController = TextEditingController();
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 30));
    PaymentMethod selectedMethod = PaymentMethod.bankTransfer;
    PaymentStatus selectedStatus = PaymentStatus.pending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number',
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  items: PaymentMethod.values
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedMethod = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: PaymentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(selectedDueDate.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDueDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (descController.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Description and valid amount are required',
                      ),
                    ),
                  );
                  return;
                }

                await context.read<PaymentsProvider>().addPayment(
                  Payment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    projectId: 'proj1',
                    clientId: '1',
                    userId: 'user1',
                    amount: amount,
                    status: selectedStatus,
                    method: selectedMethod,
                    description: descController.text.trim(),
                    dueDate: selectedDueDate,
                    createdAt: DateTime.now(),
                    paidDate: selectedStatus == PaymentStatus.completed
                        ? DateTime.now()
                        : null,
                    invoiceNumber: invoiceController.text.trim().isEmpty
                        ? null
                        : invoiceController.text.trim(),
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment added successfully')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, Payment payment) {
    final descController = TextEditingController(text: payment.description);
    final amountController = TextEditingController(
      text: payment.amount.toStringAsFixed(2),
    );
    final invoiceController = TextEditingController(
      text: payment.invoiceNumber ?? '',
    );
    DateTime selectedDueDate = payment.dueDate;
    PaymentMethod selectedMethod = payment.method;
    PaymentStatus selectedStatus = payment.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Edit Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number',
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentMethod>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  items: PaymentMethod.values
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setLocalState(() => selectedMethod = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<PaymentStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: PaymentStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setLocalState(() => selectedStatus = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text(selectedDueDate.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setLocalState(() => selectedDueDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (descController.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid details')),
                  );
                  return;
                }

                await context.read<PaymentsProvider>().updatePayment(
                  payment.copyWith(
                    description: descController.text.trim(),
                    amount: amount,
                    invoiceNumber: invoiceController.text.trim().isEmpty
                        ? null
                        : invoiceController.text.trim(),
                    dueDate: selectedDueDate,
                    method: selectedMethod,
                    status: selectedStatus,
                    paidDate: selectedStatus == PaymentStatus.completed
                        ? (payment.paidDate ?? DateTime.now())
                        : null,
                  ),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment updated successfully')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsPaid(BuildContext context, String paymentId) {
    context.read<PaymentsProvider>().markAsPaid(paymentId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
  }

  void _deletePayment(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PaymentsProvider>().deletePayment(paymentId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Payment> _getFilteredPayments(PaymentsProvider provider) {
    switch (_selectedFilter) {
      case 1:
        return provider.getPendingPayments();
      case 2:
        return provider.getCompletedPayments();
      case 3:
        return provider.getOverduePayments();
      default:
        return provider.payments;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return AppColors.successColor;
      case PaymentStatus.failed:
        return AppColors.errorColor;
      case PaymentStatus.refunded:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.undo;
    }
  }
}
