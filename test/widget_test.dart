import 'package:flutter_test/flutter_test.dart';
import 'package:odyssey/auth/validators.dart';
import 'package:odyssey/data/app_store.dart';
import 'package:odyssey/data/models.dart';
import 'package:odyssey/data/sample.dart';
import 'package:odyssey/widgets/kit.dart';

void main() {
  group('Email', () {
    test('accepts well-formed addresses', () {
      expect(validateEmail('kayeen@example.com'), isNull);
      expect(validateEmail('  mai.thao+trips@mail.co.vn '), isNull);
    });

    test('rejects empty or malformed addresses', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
      expect(validateEmail('kayeen'), isNotNull);
      expect(validateEmail('kayeen@example'), isNotNull);
      expect(validateEmail('kay een@example.com'), isNotNull);
    });
  });

  group('Passwords', () {
    test('new passwords need eight characters', () {
      expect(validateNewPassword('short'), isNotNull);
      expect(validateNewPassword('longenough'), isNull);
    });
  });

  group('Names', () {
    test('a name is required', () {
      expect(validateName('  '), isNotNull);
      expect(validateName('Kayeen'), isNull);
    });

    test('display name comes from the email', () {
      expect(nameFromEmail('kayeen.campana@example.com'), 'Kayeen');
      expect(nameFromEmail('MAI_thao@x.vn'), 'Mai');
      expect(nameFromEmail('@x.com'), 'Wayfarer');
    });

    test('an empty log-in signs in as Wayfarer', () {
      expect(nameFromEmail(''), 'Wayfarer');
    });
  });

  group('Sample data', () {
    final store = AppStore.instance;

    test('every reference resolves', () {
      for (final post in Sample.posts) {
        store.person(post.authorId);
        if (post is InvitePost) store.event(post.eventId);
      }
      for (final e in Sample.events) {
        store.person(e.hostId);
        e.attendeeIds.forEach(store.person);
        expect(e.attendeeIds.length + 1, lessThan(e.capacity));
      }
      for (final s in Sample.mapStories) {
        store.person(s.authorId);
      }
    });

    test('ids are unique', () {
      expect(Sample.posts.map((p) => p.id).toSet().length, Sample.posts.length);
      expect(
        Sample.events.map((e) => e.id).toSet().length,
        Sample.events.length,
      );
    });
  });

  group('Schedule', () {
    final store = AppStore.instance;

    test('today mixes your plans with joined events, earliest first', () {
      final items = store.itemsOn(Sample.today);
      expect(items.map((i) => i.title), contains('Pack for Hà Giang'));
      expect(items.where((i) => i.eventId == 'e-coffee'), hasLength(1));
      for (var i = 1; i < items.length; i++) {
        expect(items[i].start.isBefore(items[i - 1].start), isFalse);
      }
    });

    test('joining an expedition puts each of its days on the schedule', () {
      final ride = store.event('e-highpass');
      expect(store.isJoined(ride.id), isFalse);
      store.toggleJoin(ride.id);
      for (var d = 0; d < ride.dayCount; d++) {
        final day = ride.start.add(Duration(days: d));
        expect(
          store.itemsOn(day).where((i) => i.eventId == ride.id),
          hasLength(1),
          reason: 'day ${d + 1}',
        );
      }
      expect(
        store
            .itemsOn(ride.start.add(Duration(days: ride.dayCount)))
            .where((i) => i.eventId == ride.id),
        isEmpty,
      );
      store.toggleJoin(ride.id);
      expect(
        store.itemsOn(ride.start).where((i) => i.eventId == ride.id),
        isEmpty,
      );
    });

    test('added plans land on their day', () {
      final day = Sample.today.add(const Duration(days: 30));
      store.addPlan(
        PlanItem(
          id: 'test-plan',
          title: 'Night market',
          kind: PlanKind.food,
          start: day.add(const Duration(hours: 19)),
          length: const Duration(hours: 2),
          place: 'Somewhere',
        ),
      );
      expect(store.itemsOn(day).single.title, 'Night market');
    });
  });

  group('Feed and friends', () {
    final store = AppStore.instance;

    test('new posts go to the top and likes count once', () {
      const post = TextPost(
        id: 'test-post',
        authorId: 'me',
        ago: 'Just now',
        text: 'Hello road',
      );
      store.addPost(post);
      expect(store.posts.first.id, 'test-post');
      store.toggleLike(post.id);
      expect(store.likesOf(post), 1);
      store.toggleLike(post.id);
      expect(store.likesOf(post), 0);
    });

    testWidgets('a friend request is accepted a moment later', (tester) async {
      store.addFriend('p-lea');
      expect(store.statusOf('p-lea'), FriendStatus.requested);
      await tester.pump(const Duration(seconds: 2));
      expect(store.statusOf('p-lea'), FriendStatus.friends);
    });
  });

  group('Formatting', () {
    test('times and durations read naturally', () {
      expect(timeLabel(DateTime(2026, 11, 20, 8)), '8:00 AM');
      expect(timeLabel(DateTime(2026, 11, 20, 14, 5)), '2:05 PM');
      expect(timeLabel(DateTime(2026, 11, 20, 0, 30)), '12:30 AM');
      expect(durationLabel(const Duration(minutes: 75)), '1h 15m');
      expect(durationLabel(const Duration(minutes: 45)), '45 min');
      expect(durationLabel(const Duration(days: 4)), '4 days');
      expect(dayLabel(DateTime(2026, 11, 20)), 'Fri, 20 Nov');
    });
  });
}
