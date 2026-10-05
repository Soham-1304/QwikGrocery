import 'dart:io';

import 'harness/test_app_harness.dart';

// Tier 1 Feature Tests
import 'tier1_feature_tests/test_cart_controller.dart';
import 'tier1_feature_tests/test_category_rail.dart';
import 'tier1_feature_tests/test_checkout_features.dart';
import 'tier1_feature_tests/test_currency_formatter.dart';
import 'tier1_feature_tests/test_deals_carousel.dart';
import 'tier1_feature_tests/test_delivery_eta_pill.dart';
import 'tier1_feature_tests/test_delivery_meter.dart';
import 'tier1_feature_tests/test_models.dart';
import 'tier1_feature_tests/test_product_card.dart';
import 'tier1_feature_tests/test_product_detail_features.dart';
import 'tier1_feature_tests/test_quantity_stepper.dart';
import 'tier1_feature_tests/test_search_and_filters.dart';

// Tier 2 Boundary Tests
import 'tier2_boundary_tests/test_address_and_instruction_edges.dart';
import 'tier2_boundary_tests/test_cart_controller_adversarial.dart';
import 'tier2_boundary_tests/test_empty_cart_boundaries.dart';
import 'tier2_boundary_tests/test_free_delivery_exact_threshold.dart';
import 'tier2_boundary_tests/test_pricing_and_tax_boundaries.dart';
import 'tier2_boundary_tests/test_search_special_chars_and_edges.dart';
import 'tier2_boundary_tests/test_stock_limit_caps.dart';
import 'tier2_boundary_tests/test_wallet_balance_boundaries.dart';
import 'tier2_boundary_tests/test_zero_quantity_and_removal.dart';

// Tier 3 Cross-Feature Tests
import 'tier3_cross_feature_tests/test_cart_stepper_sync.dart';
import 'tier3_cross_feature_tests/test_checkout_payment_wallet_sync.dart';
import 'tier3_cross_feature_tests/test_search_category_rail_sync.dart';

// Tier 4 Application Flows
import 'tier4_application_flows/test_flow1_standard_grocery_run.dart';
import 'tier4_application_flows/test_flow2_subthreshold_delivery_fee.dart';
import 'tier4_application_flows/test_flow3_out_of_stock_and_caps.dart';
import 'tier4_application_flows/test_flow4_detail_fbt_and_bottom_bar.dart';
import 'tier4_application_flows/test_flow5_wallet_and_fallback_cod.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  print('================================================================');
  print('          QUICKGROCERY APP MASTER E2E TEST RUNNER               ');
  print('       Executing Tiers 1-4 Comprehensive Test Automation        ');
  print('================================================================\n');

  // --- TIER 1: FEATURE UNIT & COMPONENT TESTS ---
  print('>>> RUNNING TIER 1: FEATURE ISOLATION TESTS (12 Suites)...');
  final tier1StartPass = globalTestSummary.passed;
  final tier1StartFail = globalTestSummary.failed;

  await runModelTests();
  await runCartControllerTests();
  await runCurrencyFormatterTests();
  await runDeliveryMeterTests();
  await runDeliveryEtaPillTests();
  await runDealsCarouselTests();
  await runCategoryRailTests();
  await runProductCardTests();
  await runQuantityStepperTests();
  await runSearchAndFiltersTests();
  await runProductDetailFeaturesTests();
  await runCheckoutFeaturesTests();

  final tier1Passed = globalTestSummary.passed - tier1StartPass;
  final tier1Failed = globalTestSummary.failed - tier1StartFail;
  print('✔ TIER 1 COMPLETE: $tier1Passed passed, $tier1Failed failed\n');

  // --- TIER 2: BOUNDARY & CORNER CASE TESTS ---
  print('>>> RUNNING TIER 2: BOUNDARY & ADVERSARIAL TESTS (9 Suites)...');
  final tier2StartPass = globalTestSummary.passed;
  final tier2StartFail = globalTestSummary.failed;

  await runZeroQuantityAndRemovalTests();
  await runStockLimitCapsTests();
  await runEmptyCartBoundariesTests();
  await runFreeDeliveryExactThresholdTests();
  await runSearchSpecialCharsAndEdgesTests();
  await runPricingAndTaxBoundariesTests();
  await runWalletBalanceBoundariesTests();
  await runAddressAndInstructionEdgesTests();
  await runCartControllerAdversarialTests();

  final tier2Passed = globalTestSummary.passed - tier2StartPass;
  final tier2Failed = globalTestSummary.failed - tier2StartFail;
  print('✔ TIER 2 COMPLETE: $tier2Passed passed, $tier2Failed failed\n');

  // --- TIER 3: CROSS-FEATURE INTEGRATION TESTS ---
  print('>>> RUNNING TIER 3: CROSS-FEATURE INTEGRATION TESTS (3 Suites)...');
  final tier3StartPass = globalTestSummary.passed;
  final tier3StartFail = globalTestSummary.failed;

  await runCartStepperSyncTests();
  await runSearchCategoryRailSyncTests();
  await runCheckoutPaymentWalletSyncTests();

  final tier3Passed = globalTestSummary.passed - tier3StartPass;
  final tier3Failed = globalTestSummary.failed - tier3StartFail;
  print('✔ TIER 3 COMPLETE: $tier3Passed passed, $tier3Failed failed\n');

  // --- TIER 4: APPLICATION USER JOURNEY FLOWS ---
  print('>>> RUNNING TIER 4: END-TO-END APPLICATION FLOWS (5 Suites)...');
  final tier4StartPass = globalTestSummary.passed;
  final tier4StartFail = globalTestSummary.failed;

  await runFlow1StandardGroceryRunTests();
  await runFlow2SubthresholdDeliveryFeeTests();
  await runFlow3OutOfStockAndCapsTests();
  await runFlow4DetailFbtAndBottomBarTests();
  await runFlow5WalletAndFallbackCodTests();

  final tier4Passed = globalTestSummary.passed - tier4StartPass;
  final tier4Failed = globalTestSummary.failed - tier4StartFail;
  print('✔ TIER 4 COMPLETE: $tier4Passed passed, $tier4Failed failed\n');

  stopwatch.stop();

  // --- FINAL MASTER REPORT ---
  print('================================================================');
  print('               QUICKGROCERY TEST RUN SUMMARY                    ');
  print('================================================================');
  print('Tier 1: Feature Tests          -> Passed: $tier1Passed, Failed: $tier1Failed');
  print('Tier 2: Boundary Tests         -> Passed: $tier2Passed, Failed: $tier2Failed');
  print('Tier 3: Cross-Feature Tests    -> Passed: $tier3Passed, Failed: $tier3Failed');
  print('Tier 4: Application Flow Tests -> Passed: $tier4Passed, Failed: $tier4Failed');
  print('----------------------------------------------------------------');
  print('TOTAL TESTS EXECUTED: ${globalTestSummary.total}');
  print('PASSED:               ${globalTestSummary.passed}');
  print('FAILED:               ${globalTestSummary.failed}');
  print('EXECUTION TIME:       ${stopwatch.elapsedMilliseconds} ms');
  print('================================================================');

  if (globalTestSummary.failed > 0) {
    print('\n❌ TEST RUN FAILED with ${globalTestSummary.failed} failure(s):');
    for (final err in globalTestSummary.failureMessages) {
      print('  - $err');
    }
    exit(1);
  } else {
    print('\n🎉 ALL ${globalTestSummary.total} TESTS PASSED CLEANLY (100% SUCCESS RATE)!');
    exit(0);
  }
}
