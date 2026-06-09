import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderCode;
  const OrderStatusScreen({super.key, required this.orderCode});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  String _status = 'pending';
  bool _isLoading = true;
  bool _isRefreshing = false;

  final List<Map<String, String>> _statuses = [
    {'value': 'pending', 'label': 'Pesanan Dibuat', 'desc': 'Menunggu konfirmasi'},
    {'value': 'confirmed', 'label': 'Dikonfirmasi', 'desc': 'Pesanan diproses'},
    {'value': 'preparing', 'label': 'Dimasak', 'desc': 'Dapur sedang memasak'},
    {'value': 'delivered', 'label': 'Dikirim', 'desc': 'Pesanan dalam perjalanan'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _startPolling();
  }

  Future<void> _fetchStatus() async {
    if (_isRefreshing) return;
    
    try {
      final response = await ApiService.get('/orders/${widget.orderCode}');
      if (response['status'] != null && response['status'] != _status) {
        setState(() {
          _status = response['status'];
          _isLoading = false;
        });
      } else if (_isLoading) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Pull to refresh
  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final response = await ApiService.get('/orders/${widget.orderCode}');
      if (response['status'] != null) {
        setState(() {
          _status = response['status'];
        });
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _fetchStatus();
        _startPolling();
      }
    });
  }

  int getCurrentStep() {
    int index = _statuses.indexWhere((s) => s['value'] == _status);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Kode: ${widget.orderCode}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.green,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Kode Pesanan',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.orderCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: Stepper(
                        currentStep: getCurrentStep(),
                        controlsBuilder: (context, details) => const SizedBox.shrink(),
                        physics: const NeverScrollableScrollPhysics(),
                        steps: _statuses.map((step) {
                          int stepIndex = _statuses.indexOf(step);
                          return Step(
                            title: Text(
                              step['label']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            content: Text(
                              step['desc']!,
                              style: const TextStyle(fontSize: 11),
                            ),
                            isActive: true,
                            state: getCurrentStep() >= stepIndex
                                ? StepState.complete
                                : StepState.indexed,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.refresh, size: 32, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text(
                            'Geser ke bawah untuk refresh',
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  } 
}