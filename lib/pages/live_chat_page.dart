import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import '../services/gold_rate_service.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! I'm Sarah from Gemzi Boutique. How can I assist you today?", "isMe": false, "type": "text"},
  ];

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  void _sendMessage({String? text}) {
    final finalMsg = text ?? _controller.text;
    if (finalMsg.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": finalMsg,
        "isMe": true,
        "type": "text",
      });
    });

    _controller.clear();
    _scrollToBottom();

    // 🤖 Agent Response Logic
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      final String input = finalMsg.toLowerCase();
      
      if (input.contains("earring") || input.contains("jhumka") || input.contains("stud")) {
        _agentReply("Lotus Jhumka Collection", "assets/auth/lotusjhumka.jpeg");
      } else if (input.contains("ring")) {
        _agentReply("Gemzi Signature Diamond Ring", "assets/auth/ring1.jpeg");
      } else if (input.contains("necklace") || input.contains("pearl") || input.contains("choker")) {
        _agentReply("Royal Pearl & Gold Necklace", "assets/auth/nacklace3.jpeg");
      } else if (input.contains("coin")) {
        _agentReply("24K Premium Gold Coins", "assets/auth/coin.jpeg");
      } else if (input.contains("collection") || input.contains("show")) {
        _agentReply("Boutique Wedding Collection", "assets/auth/nacklace6.jpeg");
      } else if (input.contains("rate") || input.contains("price")) {
        final rate = GoldRateService.currentRate;
        _agentTextReply("Today's Current 24K Gold Rate is ₹${rate.toStringAsFixed(0)} per gram. This is pulled live from our market feed.");
      } else {
        _agentTextReply("I can help you browse our collections! Would you like to see Rings, Necklaces, Earrings, or Coins?");
      }
    });
  }

  void _agentTextReply(String text) {
    setState(() {
      _messages.add({"text": text, "isMe": false, "type": "text"});
    });
    _scrollToBottom();
  }

  void _agentReply(String title, String image) {
    _agentTextReply("I've found a stunning piece for you from our signature collection:");
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          "text": title,
          "image": image,
          "isMe": false,
          "type": "image"
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        elevation: 0,
        title: const Text("Sarah (Boutique Agent)", style: TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildUnifiedBubble(_messages[index]);
              },
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                _chip("View Rings", "Show me rings"),
                const SizedBox(width: 8),
                _chip("View Necklaces", "Show me necklaces"),
                const SizedBox(width: 8),
                _chip("View Earrings", "Show me earrings"),
                const SizedBox(width: 8),
                _chip("View Coins", "Show me coins"),
                const SizedBox(width: 8),
                _chip("Gold Rate", "What is the gold rate?"),
              ],
            ),
          ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildUnifiedBubble(Map<String, dynamic> msg) {
    final bool isMe = msg["isMe"] ?? false;
    final bool isImage = msg["type"] == "image";

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? richGold : surfaceDark,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 5),
              bottomRight: Radius.circular(isMe ? 5 : 20),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    msg["image"], 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 100, 
                      color: Colors.white12, 
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white38))
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  msg["text"],
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                    fontSize: 14,
                    fontWeight: isImage ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String command) {
    return GestureDetector(
      onTap: () => _sendMessage(text: command),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: richGold.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(color: richGold, fontSize: 12)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: surfaceDark,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Type or tap a chip...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(icon: Icon(Icons.send_rounded, color: richGold), onPressed: () => _sendMessage()),
          ],
        ),
      ),
    );
  }
}
