import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/onboarding_step.dart';

// Current page index
final onboardingPageProvider = StateProvider<int>((ref) => 0);

// Has user completed onboarding?
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_completed_onboarding') ?? false;
});

// Onboarding notifier
final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingState {
  final int currentPage;
  final List<OnboardingStep> steps;
  final bool isCompleted;

  const OnboardingState({
    required this.currentPage,
    required this.steps,
    required this.isCompleted,
  });

  OnboardingState copyWith({
    int? currentPage,
    List<OnboardingStep>? steps,
    bool? isCompleted,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get isLastPage => currentPage == steps.length - 1;
  bool get isFirstPage => currentPage == 0;
  int get totalPages => steps.length;
  double get progress => (currentPage + 1) / totalPages;
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState(
      currentPage: 0,
      steps: OnboardingStep.steps,
      isCompleted: false,
    );
  }

  void nextPage() {
    if (!state.isLastPage) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (!state.isFirstPage) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    state = state.copyWith(isCompleted: true);
  }

  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }
}