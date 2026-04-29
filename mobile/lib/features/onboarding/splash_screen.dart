import 'package:flutter/material.dart';

import '../../core/i18n/campus_copy.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.copy, required this.onContinue});

  final CampusCopy copy;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(
                Icons.travel_explore,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'CampusSense',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                copy.tagline,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Text(copy.introBody, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CapabilityChip(
                    icon: Icons.my_location,
                    label: copy.text('gps'),
                  ),
                  _CapabilityChip(
                    icon: Icons.directions_walk,
                    label: copy.text('motion'),
                  ),
                  _CapabilityChip(
                    icon: Icons.cloud_queue,
                    label: copy.text('api'),
                  ),
                  _CapabilityChip(
                    icon: Icons.people_outline,
                    label: copy.text('reports'),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(copy.startSensing),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
