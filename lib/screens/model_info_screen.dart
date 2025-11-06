import 'package:flutter/material.dart';
import '../constants/llm_models.dart';
import 'package:intl/intl.dart';

class ModelInfoScreen extends StatelessWidget {
  final List<LLMModel> models;

  const ModelInfoScreen({super.key, required this.models});

  @override
  Widget build(BuildContext context) {
    // Group models by organization
    final groupedModels = <String, List<LLMModel>>{};
    for (final model in models) {
      groupedModels.putIfAbsent(model.organization, () => []).add(model);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Models'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: models.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No models available',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: groupedModels.length,
                itemBuilder: (context, index) {
                  final org = groupedModels.keys.elementAt(index);
                  final orgModels = groupedModels[org]!;
      
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          org,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      ...orgModels.map((model) => ModelCard(model: model)),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class ModelCard extends StatelessWidget {
  final LLMModel model;

  const ModelCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          model.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatContextLength(model.contextLength)} context',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.fingerprint, 'Model ID', model.id),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.business,
                  'Organization',
                  model.organization,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.category, 'Type', model.type),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.memory,
                  'Context Length',
                  _formatContextLength(model.contextLength),
                ),
                if (model.license != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.gavel, 'License', model.license!),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Created',
                  DateFormat('MMM d, yyyy').format(model.created),
                ),
                if (model.pricing != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Pricing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.arrow_downward,
                    'Input',
                    model.pricing!.inputPriceFormatted,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.arrow_upward,
                    'Output',
                    model.pricing!.outputPriceFormatted,
                  ),
                  if (model.pricing!.hourly > 0) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.access_time,
                      'Hourly',
                      '\$${model.pricing!.hourly.toStringAsFixed(2)}/hour',
                    ),
                  ],
                ],
                // if (model.link != null && model.link!.isNotEmpty) ...[
                //   const SizedBox(height: 16),
                //   ElevatedButton.icon(
                //     onPressed: () {
                //       // Could open link in browser //TODO
                //     },
                //     icon: const Icon(Icons.link),
                //     label: const Text('More Info'),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatContextLength(int length) {
    if (length >= 1000000) {
      return '${(length / 1000000).toStringAsFixed(1)}M';
    } else if (length >= 1000) {
      return '${(length / 1000).toStringAsFixed(0)}K';
    }
    return length.toString();
  }
}
