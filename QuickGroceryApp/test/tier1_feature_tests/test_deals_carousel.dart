import 'package:qwik_grocery_app/models/banner_item.dart';
import '../harness/test_app_harness.dart';
import '../harness/test_components.dart';
import '../harness/test_fixtures.dart';

Future<void> runDealsCarouselTests() async {
  await testGroup('Tier 1: Deals Hero Carousel', () async {
    await testCase('Renders seeded banner items correctly', () {
      final carousel = DealsCarousel(banners: TestFixtures.allBanners);
      expect(carousel.banners.length, equals(3));
      expect(carousel.banners.first.title, contains('50% OFF'));
    });

    await testCase('Displays badge tag, title, and subtitle of current banner', () {
      final banner = TestFixtures.allBanners.first;
      expect(banner.badgeText, equals('50% OFF'));
      expect(banner.title, equals('FLAT 50% OFF Fresh Veggies'));
      expect(banner.subtitle, equals('Harvested this morning from local farms'));
    });

    await testCase('next() advances active carousel index', () {
      final carousel = DealsCarousel(banners: TestFixtures.allBanners);
      final state = carousel.createState() as dynamic;
      state.widget = carousel;
      expect(state.currentIndex, equals(0));
      state.next();
      expect(state.currentIndex, equals(1));
      state.next();
      expect(state.currentIndex, equals(2));
    });

    await testCase('next() loops back to index 0 on overflow', () {
      final carousel = DealsCarousel(banners: TestFixtures.allBanners);
      final state = carousel.createState() as dynamic;
      state.widget = carousel;
      state.selectIndex(2); // last item
      state.next();
      expect(state.currentIndex, equals(0));
    });

    await testCase('selectIndex sets arbitrary valid index', () {
      final carousel = DealsCarousel(banners: TestFixtures.allBanners);
      final state = carousel.createState() as dynamic;
      state.widget = carousel;
      state.selectIndex(1);
      expect(state.currentIndex, equals(1));
    });

    await testCase('Handles empty banner list without crashing', () {
      const emptyCarousel = DealsCarousel(banners: []);
      final state = emptyCarousel.createState() as dynamic;
      state.widget = emptyCarousel;
      // calling next on empty shouldn't crash
      state.next();
      expect(state.currentIndex, equals(0));
    });

    await testCase('Tapping banner fires onBannerTap callback', () {
      BannerItem? tappedBanner;
      final carousel = DealsCarousel(
        banners: TestFixtures.allBanners,
        onBannerTap: (b) => tappedBanner = b,
      );
      carousel.onBannerTap?.call(TestFixtures.allBanners[1]);
      expect(tappedBanner, isNotNull);
      expect(tappedBanner!.id, equals('banner_2'));
    });

    await testCase('Banners contain action route or category filter metadata', () {
      for (final banner in TestFixtures.allBanners) {
        expect(banner.categoryFilter, isNotNull);
      }
    });
  });
}

Future<void> main() async {
  await runDealsCarouselTests();
  globalTestSummary.printReport('Tier 1 DealsCarousel');
}
