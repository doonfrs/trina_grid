import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trina_grid/trina_grid.dart';

// A simple constant to determine if we are in a test environment
// Use a function that returns true if Flutter's testing flag is set
// This avoids directly importing flutter_test which would create a circular dependency
bool get _isTestEnvironment =>
    WidgetsBinding.instance.toString().contains('TestWidgetsFlutterBinding');

class TrinaVerticalScrollBar extends StatefulWidget {
  const TrinaVerticalScrollBar({
    super.key,
    required this.stateManager,
    required this.verticalScrollExtentNotifier,
    required this.verticalViewportExtentNotifier,
    required this.verticalScrollOffsetNotifier,
    required this.context,
    required this.height,
  });

  final TrinaGridStateManager stateManager;
  final ValueNotifier<double> verticalScrollExtentNotifier;
  final ValueNotifier<double> verticalViewportExtentNotifier;
  final ValueNotifier<double> verticalScrollOffsetNotifier;
  final BuildContext context;
  final double height;

  @override
  State<TrinaVerticalScrollBar> createState() => _TrinaVerticalScrollBarState();
}

class _TrinaVerticalScrollBarState extends State<TrinaVerticalScrollBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hovering = false;
  bool _isDragging = false;
  bool _isThumbHovered = false;

  // Track the last scroll position to detect scrolling
  double _lastScrollOffset = 0;

  // Timer for hiding scrollbar
  Timer? _hideTimer;

  // Variables for drag functionality

  @override
  void initState() {
    super.initState();

    // Create a fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Initialize the fade controller based on isAlwaysShown setting
    if (widget.stateManager.configuration.scrollbar.isAlwaysShown) {
      _fadeController.value = 1.0;
    } else {
      _fadeController.value = 0.0;
    }

    // Listen for scroll changes to show the scrollbar temporarily
    widget.verticalScrollOffsetNotifier.addListener(_handleScrollChange);

    // Listen to stateManager for configuration changes
    widget.stateManager.addListener(_handleConfigChange);
  }

  void _handleConfigChange() {
    // Check configuration changes, specifically scrollbar settings
    final scrollConfig = widget.stateManager.configuration.scrollbar;
    if (scrollConfig.isAlwaysShown && scrollConfig.thumbVisible) {
      // Always show the scrollbar
      _fadeController.animateTo(1.0);
    } else if (!scrollConfig.thumbVisible) {
      // Hide scrollbar if thumbVisible is false
      _fadeController.animateTo(0.0);
    } else if (!scrollConfig.isAlwaysShown) {
      // Hide scrollbar if not always shown and not actively scrolling/hovering
      if (!_hovering && !_isDragging) {
        _fadeController.animateTo(0.0);
      }
    }
  }

  @override
  void didUpdateWidget(TrinaVerticalScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Get old and new configurations
    final oldConfig = oldWidget.stateManager.configuration.scrollbar;
    final newConfig = widget.stateManager.configuration.scrollbar;

    // Check for changes in visibility settings
    if (oldConfig.isAlwaysShown != newConfig.isAlwaysShown ||
        oldConfig.thumbVisible != newConfig.thumbVisible) {
      // When isAlwaysShown or thumbVisible changes
      if (newConfig.isAlwaysShown && newConfig.thumbVisible) {
        // Always show the scrollbar
        _fadeController.animateTo(1.0);
      } else if (!newConfig.thumbVisible) {
        // Hide scrollbar if thumbVisible is false
        _fadeController.animateTo(0.0);
      } else if (!newConfig.isAlwaysShown) {
        // Hide scrollbar if not always shown and not actively scrolling/hovering
        if (!_hovering && !_isDragging) {
          _fadeController.animateTo(0.0);
        }
      }
    }
  }

  void _handleScrollChange() {
    final scrollConfig = widget.stateManager.configuration.scrollbar;
    final currentOffset = widget.verticalScrollOffsetNotifier.value;

    // If not set to always shown and we detect scrolling
    if (!scrollConfig.isAlwaysShown && currentOffset != _lastScrollOffset) {
      _showScrollbar();
      _lastScrollOffset = currentOffset;
    }
  }

  void _showScrollbar() {
    _fadeController.forward();

    // Cancel any existing timer
    _hideTimer?.cancel();

    // If not hovering or dragging, hide after delay
    if (!widget.stateManager.configuration.scrollbar.isAlwaysShown &&
        !_hovering &&
        !_isDragging) {
      // Use a shorter duration in tests to avoid lingering timers
      final duration = Duration(milliseconds: _isTestEnvironment ? 300 : 3000);

      _hideTimer = Timer(duration, () {
        if (!_hovering && !_isDragging && mounted) {
          _fadeController.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.verticalScrollOffsetNotifier.removeListener(_handleScrollChange);
    widget.stateManager.removeListener(_handleConfigChange);

    // Cancel any pending timer
    _hideTimer?.cancel();
    _hideTimer = null;

    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollConfig = widget.stateManager.configuration.scrollbar;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
          if (!scrollConfig.isAlwaysShown) {
            _fadeController.forward();
          }
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
          _isThumbHovered = false;
          if (!scrollConfig.isAlwaysShown && !_isDragging) {
            _fadeController.reverse();
          }
        });
      },
      child: GestureDetector(
        onTapUp: (details) {
          // Handle clicks on the track to jump to that position
          final scrollController = widget.stateManager.scroll.bodyRowsVertical;
          if (scrollController == null) return;

          final scrollExtent = widget.verticalScrollExtentNotifier.value;
          final viewportExtent = widget.verticalViewportExtentNotifier.value;

          if (scrollExtent <= 0) return;

          final double thumbHeight =
              (viewportExtent / (viewportExtent + scrollExtent)) *
              widget.height;

          // Get the local Y position of the tap
          final tapY = details.localPosition.dy;

          // Calculate the scroll position where the center of the thumb should be at tapY
          // thumbPosition = (scrollOffset / scrollExtent) * (widget.height - thumbHeight)
          // Solving for scrollOffset when thumbPosition + thumbHeight/2 = tapY:
          final targetThumbPosition = tapY - (thumbHeight / 2);
          final newScrollOffset =
              (targetThumbPosition / (widget.height - thumbHeight)) *
              scrollExtent;

          // Clamp to valid range
          final clampedOffset = newScrollOffset.clamp(
            0.0,
            scrollController.position.maxScrollExtent,
          );

          // Use animateTo for smooth scrolling instead of jumpTo
          scrollController.animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          );
        },
        onPanDown: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
            if (!scrollConfig.isAlwaysShown && !_hovering) {
              _fadeController.reverse();
            }
          });
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
            if (!scrollConfig.isAlwaysShown && !_hovering) {
              _fadeController.reverse();
            }
          });
        },
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ValueListenableBuilder<double>(
            valueListenable: widget.verticalScrollExtentNotifier,
            builder: (context, scrollExtent, _) {
              if (scrollExtent <= 0) {
                return SizedBox(width: scrollConfig.thickness);
              }

              return ValueListenableBuilder<double>(
                valueListenable: widget.verticalViewportExtentNotifier,
                builder: (context, viewportExtent, _) {
                  final double thumbHeight =
                      (viewportExtent / (viewportExtent + scrollExtent)) *
                      widget.height;

                  return ValueListenableBuilder<double>(
                    valueListenable: widget.verticalScrollOffsetNotifier,
                    builder: (context, scrollOffset, _) {
                      final double thumbPosition =
                          (scrollOffset / scrollExtent) *
                          (widget.height - thumbHeight);

                      return SizedBox(
                        width: scrollConfig.thickness + 4, // Add padding
                        height: widget.height,
                        child: Stack(
                          children: [
                            // Track
                            if (scrollConfig.showTrack)
                              Container(
                                width: scrollConfig.thickness,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _hovering
                                      ? scrollConfig.effectiveTrackHoverColor
                                      : scrollConfig.effectiveTrackColor,
                                  borderRadius: BorderRadius.circular(
                                    scrollConfig.effectiveRadius,
                                  ),
                                ),
                              ),
                            // Thumb
                            if (scrollConfig.thumbVisible)
                              Positioned(
                                top: thumbPosition.isNaN ? 0 : thumbPosition,
                                height: thumbHeight.isNaN
                                    ? widget.height
                                    : thumbHeight.clamp(
                                        scrollConfig.minThumbLength >
                                                widget.height
                                            ? widget.height
                                            : scrollConfig.minThumbLength,
                                        widget.height,
                                      ),
                                width: scrollConfig.thickness,
                                left: widget.stateManager.isRTL ? 2 : null,
                                right: widget.stateManager.isRTL ? null : 2,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.grab,
                                  onEnter: (_) {
                                    if (!_isThumbHovered) {
                                      setState(() {
                                        _isThumbHovered = true;
                                      });
                                    }
                                  },
                                  onExit: (_) {
                                    if (_isThumbHovered) {
                                      setState(() {
                                        _isThumbHovered = false;
                                      });
                                    }
                                  },
                                  child: GestureDetector(
                                    onVerticalDragStart:
                                        scrollConfig.isDraggable
                                        ? (details) {
                                            setState(() {
                                              _isDragging = true;
                                            });
                                          }
                                        : null,
                                    onVerticalDragUpdate:
                                        scrollConfig.isDraggable
                                        ? (details) {
                                            // Direct thumb manipulation approach
                                            final double dragDelta =
                                                details.delta.dy;

                                            // Calculate how much to scroll based on thumb movement
                                            // The available space for the thumb to move is (widget.height - thumbHeight)
                                            // The total scrollable content is scrollExtent
                                            final double scrollableRatio =
                                                scrollExtent /
                                                (widget.height - thumbHeight);
                                            final double scrollDelta =
                                                dragDelta * scrollableRatio;

                                            // Get the scroll controller
                                            final scrollController = widget
                                                .stateManager
                                                .scroll
                                                .bodyRowsVertical;
                                            if (scrollController != null &&
                                                scrollController.hasClients) {
                                              // Apply the scroll by adding delta to current position
                                              final currentOffset =
                                                  scrollController.offset;
                                              final newOffset =
                                                  (currentOffset + scrollDelta)
                                                      .clamp(
                                                        0.0,
                                                        scrollController
                                                            .position
                                                            .maxScrollExtent,
                                                      );

                                              // Use jumpTo for immediate response during drag
                                              scrollController.jumpTo(
                                                newOffset,
                                              );
                                            }
                                          }
                                        : null,
                                    onVerticalDragEnd: scrollConfig.isDraggable
                                        ? (_) {
                                            setState(() {
                                              _isDragging = false;
                                              if (!scrollConfig.isAlwaysShown &&
                                                  !_hovering) {
                                                _fadeController.reverse();
                                              }
                                            });
                                          }
                                        : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isThumbHovered || _isDragging
                                            ? scrollConfig
                                                  .effectiveThumbHoverColor
                                            : scrollConfig.effectiveThumbColor,
                                        borderRadius: BorderRadius.circular(
                                          scrollConfig.effectiveRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
