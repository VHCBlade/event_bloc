import 'package:event_bloc/src/event_bloc/event_channel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlocEventChannelProvider {
  /// Convenience function that gets the nearest [BlocEventChannel] in the [context].
  static BlocEventChannel of(BuildContext context) =>
      context.read<BlocEventChannel>();
}
