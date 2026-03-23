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
              title: const Text('Add Payment / Invoice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Invoice Title (e.g. Milestone 1)'),
                    ),
                    const SizedBox(height: 10),
                    Consumer<ClientsProvider>(
                      builder: (context, clientsProvider, child) {
                        if (clientsProvider.clients.isEmpty) {
                          return const Text("Please add a client first.");
                        }
                        return DropdownButtonFormField<String>(
                          value: selectedClientId,
                          hint: const Text("Select Client"),
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (\$)',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text(selectedDueDate == null 
                            ? 'No Due Date Chosen' 
                            : 'Due: ${DateFormat('MMM dd, yyyy').format(selectedDueDate!)}'),
                        const Spacer(),
                        TextButton(
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
                          child: const Text('Pick Date'),
                        ),
                      ],
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
                  onPressed: () {
                    final amount = double.tryParse(amountController.text);
                    if (titleController.text.isNotEmpty && selectedClientId != null && selectedDueDate != null && amount != null) {
                      Provider.of<PaymentsProvider>(context, listen: false).addPayment(
                        selectedClientId!,
                        titleController.text,
                        amount,
                        selectedDueDate!,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields correctly')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments Overview'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaymentDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer2<PaymentsProvider, ClientsProvider>(
        builder: (context, paymentsProvider, clientsProvider, child) {
          if (paymentsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentsProvider.payments.isEmpty) {
            return const Center(child: Text("No payments found. Add an invoice above."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: paymentsProvider.payments.length,
            itemBuilder: (context, index) {
              final payment = paymentsProvider.payments[index];
              
              String clientName = "Unknown Client";
              try {
                if (clientsProvider.clients.isNotEmpty) {
                    clientName = clientsProvider.clients.firstWhere((c) => c.id == payment.clientId).name;
                }
              } catch (e) {
                // Ignore if not found
              }

              final isCompleted = payment.status == 'Completed';

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              payment.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '\$${payment.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Client: $clientName', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Due Date: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}'),
                          if (isCompleted && payment.paidDate != null)
                             Text('Paid: ${DateFormat('MMM dd, yyyy').format(payment.paidDate!)}', 
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(payment.status),
                            backgroundColor: isCompleted 
                                ? Colors.green.withValues(alpha: 0.2) 
                                : Colors.orange.withValues(alpha: 0.2),
                          ),
                          Row(
                            children: [
                                if (!isCompleted)
                                    TextButton.icon(
                                        onPressed: () {
                                            Provider.of<PaymentsProvider>(context, listen: false).markAsPaid(payment.id);
                                        }, 
                                        icon: const Icon(Icons.check_circle_outline, color: Colors.green), 
                                        label: const Text('Mark Paid', style: TextStyle(color: Colors.green))
                                    ),
                                IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                        showDialog(
                                            context: context, 
                                            builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Invoice?'),
                                                content: const Text('This action cannot be undone.'),
                                                actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                    TextButton(
                                                        onPressed: () {
                                                            Provider.of<PaymentsProvider>(context, listen: false).deletePayment(payment.id);
                                                            Navigator.pop(ctx);
                                                        }, 
                                                        child: const Text('Delete', style: TextStyle(color: Colors.red))
                                                    ),
                                                ],
                                            )
                                        );
                                    },
                                ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
