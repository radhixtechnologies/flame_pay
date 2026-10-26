import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/models/faq_model.dart';

class SupportController extends GetxController {
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final categories = ['All', 'Wallet & Payments', 'Recharge & Bills', 'KYC & Security'].obs;

  final expandedIndex = (-1).obs;

  // Ticket Form
  final ticketSubjectController = TextEditingController();
  final ticketDescriptionController = TextEditingController();
  final ticketTxnIdController = TextEditingController();
  final isSubmittingTicket = false.obs;

  List<FaqItemModel> get filteredFaqs {
    final query = searchQuery.value.trim().toLowerCase();
    final cat = selectedCategory.value;

    return MockPhase5Data.faqs.where((faq) {
      final matchesCat = (cat == 'All') || (faq.category == cat);
      final matchesQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  void onClose() {
    ticketSubjectController.dispose();
    ticketDescriptionController.dispose();
    ticketTxnIdController.dispose();
    super.onClose();
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void toggleFaq(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }

  void openLiveChat() {
    Get.bottomSheet(
      Container(
        height: 480,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF4FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FlamePay AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Online • Replies instantly', style: TextStyle(color: AppColors.success, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _chatBubble('Hello Rahul! Welcome to FlamePay 24x7 Support. How can I assist you today?', isBot: true),
                  _chatBubble('I have an issue with my recent recharge of ₹349.', isBot: false),
                  _chatBubble('I found your recent recharge FP2026102601 for ₹349 to Jio (+91 9876543210). Status is marked "Success". Operator Reference ID: JIO99182318. Is this the one you need help with?', isBot: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () {
                      Get.snackbar('Message Sent', 'Agent will respond shortly', snackPosition: SnackPosition.BOTTOM);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _chatBubble(String text, {required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isBot ? const Color(0xFFF2F4F7) : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: isBot ? AppColors.navyText : Colors.white, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }

  void openTicketSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Raise Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text('Our priority dispute team responds within 2 hours', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: ticketSubjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g. Recharge debited but not received',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ticketTxnIdController,
                decoration: InputDecoration(
                  labelText: 'Transaction ID (Optional)',
                  hintText: 'e.g. FP2026102601',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ticketDescriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Detailed Description',
                  hintText: 'Describe what happened...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void submitTicket() {
    if (ticketSubjectController.text.trim().isEmpty || ticketDescriptionController.text.trim().isEmpty) {
      Get.snackbar('Missing Details', 'Please fill subject and description', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(); // close sheet

    final ticketId = 'TCK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ticket Created!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your ticket #$ticketId has been registered.'),
            const SizedBox(height: 8),
            const Text('You will receive SMS and in-app notification updates as our dispute desk resolves this.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );

    ticketSubjectController.clear();
    ticketDescriptionController.clear();
    ticketTxnIdController.clear();
  }
}
