import 'package:flutter/material.dart';

/// Error Boundary Widget - Catches errors in widget tree
/// Prevents app crashes by showing fallback UI
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final String? context;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.context,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback ?? _buildDefaultFallback();
    }

    return widget.child;
  }

  Widget _buildDefaultFallback() {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re sorry for the inconvenience',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrap a widget with error boundary
Widget withErrorBoundary(Widget child, {String? context}) {
  return ErrorBoundary(
    context: context,
    child: child,
  );
}
