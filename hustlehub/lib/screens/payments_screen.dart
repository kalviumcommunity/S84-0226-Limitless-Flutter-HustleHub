import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hustlehub/providers/payments_provider.dart';
import 'package:hustlehub/providers/clients_provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentsProvider>(context, listen: false).fetchPayments();
      Provider.of<ClientsProvider>(context, listen: false).fetchClients();
    });
  }

  void _showAddPaymentDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDueDate;
    String? selectedClientId;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(
                      controller: titleController,
                      label: 'Invoice Title',
                      hint: 'e.g. Milestone 1',
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 20),
                    Consumer<ClientsProvider>(
                      builder: (context, clientsProvider, child) {
                        if (clientsProvider.clients.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: const Text("⚠️ Please add a client first."),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedClientId,
                          hint: const Text("Select Client"),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey.withValues(alpha: 0.05),
                          ),
                          onChanged: (val) {
                            setState(() {
                              selectedClientId = val;
                            });
                          },
                          items: clientsProvider.clients.map((client) {
                            return DropdownMenuItem(
                              value: client.id,
                              child: Text(client.name),
                            );
                          }).toList(),
                        );
                      }
                    ),
                    const SizedBox(height: 20),
                    _buildDialogTextField(
                      controller: amountController,
                      label: 'Amount',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDueDate == null 
                                  ? '📅 Tap to select due date' 
                                  : 'Due: ${DateFormat('MMM dd, yyyy').format(selectedDueDate!)}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDueDate = pickedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Pick'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (titleController.text.isNotEmpty && selectedClientId != null && selectedDueDate != null && amount != null && amount > 0) {
                      Provider.of<PaymentsProvider>(context, listen: false).addPayment(
                        selectedClientId!,
                        titleController.text,
                        amount,
                        selectedDueDate!,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Invoice added successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Please fill all fields correctly'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Add Invoice'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Payments & Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
      body: Consumer2<PaymentsProvider, ClientsProvider>(
        builder: (context, paymentsProvider, clientsProvider, child) {
          final filteredPayments = paymentsProvider.payments.where((p) {
            return p.title.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          // Calculate stats
          double totalAmount = paymentsProvider.payments.fold(0, (sum, p) => sum + p.amount);
          double completedAmount = paymentsProvider.payments
              .where((p) => p.status == 'Completed')
              .fold(0, (sum, p) => sum + p.amount);
          double pendingAmount = totalAmount - completedAmount;

          return Column(
            children: [
              // Stats Header
              if (paymentsProvider.payments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard(
                        label: 'Total',
                        value: '\$${totalAmount.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        label: 'Paid',
                        value: '\$${completedAmount.toStringAsFixed(2)}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        label: 'Pending',
                        value: '\$${pendingAmount.toStringAsFixed(2)}',
                        icon: Icons.hourglass_bottom,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search invoices...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Payments List
              Expanded(
                child: paymentsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPayments.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              await Future.wait([
                                paymentsProvider.fetchPayments(),
                                clientsProvider.fetchClients(),
                              ]);
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: filteredPayments.length,
                              itemBuilder: (context, index) {
                                final payment = filteredPayments[index];
                                String clientName = "Unknown Client";
                                try {
                                  if (clientsProvider.clients.isNotEmpty) {
                                    clientName = clientsProvider.clients
                                        .firstWhere((c) => c.id == payment.clientId)
                                        .name;
                                  }
                                } catch (e) {
                                  // Ignore if not found
                                }

                                final isCompleted = payment.status == 'Completed';
                                final daysUntilDue =
                                    payment.dueDate.difference(DateTime.now()).inDays;
                                final isOverdue = daysUntilDue < 0 && !isCompleted;
                                final isUrgent = daysUntilDue <= 3 && !isCompleted;

                                return _buildPaymentCard(
                                  payment: payment,
                                  clientName: clientName,
                                  isCompleted: isCompleted,
                                  isOverdue: isOverdue,
                                  isUrgent: isUrgent,
                                  paymentsProvider: paymentsProvider,
                                  context: context,
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required dynamic payment,
    required String clientName,
    required bool isCompleted,
    required bool isOverdue,
    required bool isUrgent,
    required PaymentsProvider paymentsProvider,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue
                ? Colors.red.withValues(alpha: 0.3)
                : isUrgent
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.15)
                          : isOverdue
                              ? Colors.red.withValues(alpha: 0.15)
                              : isUrgent
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isOverdue
                              ? Icons.error
                              : isUrgent
                                  ? Icons.warning
                                  : Icons.schedule,
                      color: isCompleted
                          ? Colors.green
                          : isOverdue
                              ? Colors.red
                              : isUrgent
                                  ? Colors.orange
                                  : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          clientName,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 12),

              // Date and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd, yyyy').format(payment.dueDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted && payment.paidDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Paid On',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM dd, yyyy').format(payment.paidDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  Chip(
                    label: Text(
                      payment.status,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: isCompleted
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.orange.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              if (!isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        paymentsProvider.markAsPaid(payment.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Invoice marked as paid'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark Paid'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _confirmDeletePayment(context, payment.id, payment.title, paymentsProvider);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePayment(
    BuildContext context,
    String paymentId,
    String title,
    PaymentsProvider paymentsProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text('Delete "$title"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              paymentsProvider.deletePayment(paymentId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️  Invoice deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.blue.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Invoices Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first invoice',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
