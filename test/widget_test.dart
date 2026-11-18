import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssey/auth/validators.dart';
import 'package:odyssey/data/app_store.dart';
import 'package:odyssey/data/intro_prefs.dart';
import 'package:odyssey/data/models.dart';
import 'package:odyssey/data/photo_credits.dart';
import 'package:odyssey/data/sample.dart';
import 'package:odyssey/widgets/kit.dart';
import 'package:odyssey/widgets/photo.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      expect(
        Sample.journal.map((e) => e.id).toSet().length,
        Sample.journal.length,
      );
    });

    test('journal entries point at real posts and pins', () {
      for (final e in Sample.journal) {
        expect(e.shared, e.postId != null || e.pinId != null, reason: e.id);
        if (e.postId != null) {
          expect(Sample.posts.where((p) => p.id == e.postId), hasLength(1));
        }
        if (e.pinId != null) {
          expect(Sample.mapStories.where((s) => s.id == e.pinId), hasLength(1));
        }
      }
    });

    test('every photo has a file and a credit', () {
      final used = <Photo>{
        ...Photos.covers,
        for (final p in Sample.people) p.cover,
        for (final p in Sample.posts.whereType<StoryPost>()) ...p.photos,
        for (final e in Sample.events) e.photo,
        for (final s in Sample.mapStories) s.photo,
        for (final p in Sample.plans) ?p.photo,
        for (final e in Sample.journal) ...e.photos,
      };
      final credited = {for (final c in photoCredits) c.photo};
      for (final photo in used) {
        expect(
          File('assets/photos/${photo.name}.jpg').existsSync(),
          isTrue,
          reason: photo.name,
        );
        expect(credited, contains(photo.name));
      }
      for (final name in credited) {
        expect(File('assets/photos/$name.jpg').existsSync(), isTrue);
      }
    });
  });

  group('Journal', () {
    final store = AppStore.instance;

    test('a private entry stays out of Moments until you share it', () {
      final before = store.posts.length;
      final entry = store.write(
        kind: EntryKind.story,
        title: 'Quiet morning',
        paragraphs: const ['Mist on the river.'],
        place: 'Pakbeng, Laos',
        photos: const [Photos.pakbengBoats, Photos.mekongSunset],
        share: false,
      );
      expect(store.journal.first.id, entry.id);
      expect(store.posts.length, before);
      expect(store.entry(entry.id)!.shared, isFalse);

      store.shareEntry(entry.id);
      final shared = store.entry(entry.id)!;
      expect(shared.shared, isTrue);
      expect(store.posts.first.id, shared.postId);
      final post = store.posts.first as StoryPost;
      expect(post.title, 'Quiet morning');
      expect(post.photos, hasLength(2));
    });

    test('a shared note becomes a text post, with or without a photo', () {
      final entry = store.write(
        kind: EntryKind.note,
        paragraphs: const ['Fuel up at Mae Malai.'],
        place: 'Pai, Thailand',
      );
      expect(entry.shared, isTrue);
      expect((store.posts.first as TextPost).photo, isNull);

      store.write(
        kind: EntryKind.note,
        paragraphs: const ['Sunset from the canyon.'],
        place: 'Pai, Thailand',
        photos: const [Photos.paiCanyon],
      );
      expect((store.posts.first as TextPost).photo, Photos.paiCanyon);
    });

    test('deleting an entry takes its post off Moments', () {
      final entry = store.write(
        kind: EntryKind.note,
        paragraphs: const ['Delete me.'],
        place: 'Hà Nội, Vietnam',
      );
      expect(store.post(entry.postId!), isNotNull);
      store.deleteEntry(entry.id);
      expect(store.entry(entry.id), isNull);
      expect(store.post(entry.postId!), isNull);
    });

    test('pinning a story keeps it in the journal too', () {
      store.pinStory(
        MapStory(
          id: 'm-test',
          authorId: 'me',
          title: 'Test pin',
          note: 'Here.',
          place: 'Hội An, Vietnam',
          point: store.home,
          photo: Photos.hoiAnStreet,
          likes: 0,
          ago: 'Just now',
        ),
      );
      final pinned = store.journal.firstWhere((e) => e.pinId == 'm-test');
      expect(pinned.kind, EntryKind.pin);
      expect(pinned.shared, isTrue);
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

  group('Plans and joined events', () {
    final store = AppStore.instance;

    test('a plan can be written up only once you have been', () {
      final past = store.plan('pl-duonglam')!;
      final ahead = store.plan('pl-pass')!;
      expect(store.canWriteUp(past), isTrue);
      expect(store.canWriteUp(ahead), isFalse);
    });

    test(
      'writing up a plan links it, and removing the plan keeps the entry',
      () {
        final plan = store.plan('pl-duonglam')!;
        final entry = store.write(
          kind: EntryKind.story,
          title: 'Laterite walls',
          paragraphs: const ['The village is built from the hill itself.'],
          place: plan.place,
          photos: const [Photos.vanMieu],
          share: false,
          from: plan,
        );
        expect(store.plan(plan.id)!.journalId, entry.id);
        expect(entry.date, plan.start);

        store.removePlan(plan.id);
        expect(store.plan(plan.id), isNull);
        expect(store.entry(entry.id), isNotNull);
      },
    );

    test('deleting a written-up entry frees the plan to be written again', () {
      final plan = store.plan('pl-trangan')!;
      expect(plan.journalId, 'j-trangan');
      store.deleteEntry('j-trangan');
      expect(store.plan(plan.id)!.journalId, isNull);
    });

    test('taking an upcoming event off the schedule leaves it', () {
      store.toggleJoin('e-angkor');
      expect(store.isJoined('e-angkor'), isTrue);
      expect(store.removeEventFromSchedule('e-angkor'), isTrue);
      expect(store.isJoined('e-angkor'), isFalse);
    });

    test('a past event leaves the calendar but stays attended', () {
      final sketch = store.event('e-sketch');
      expect(store.attended(sketch), isTrue);
      final day = sketch.start;
      expect(
        store.itemsOn(day).where((i) => i.eventId == sketch.id),
        isNotEmpty,
      );

      expect(store.removeEventFromSchedule(sketch.id), isFalse);
      expect(store.itemsOn(day).where((i) => i.eventId == sketch.id), isEmpty);
      expect(store.attended(sketch), isTrue);
      expect(store.attendedEvents, contains(sketch));

      store.toggleJoin(sketch.id); // Can't leave something that's over.
      expect(store.isJoined(sketch.id), isTrue);
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

  group('Intro tour', () {
    test('plays after sign up, not on a first log in', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await IntroPrefs.shouldShow(afterSignUp: true), isTrue);
      expect(await IntroPrefs.shouldShow(afterSignUp: false), isFalse);
    });

    test('comes back on later log ins once seen', () async {
      SharedPreferences.setMockInitialValues({});
      await IntroPrefs.markSeen();
      expect(await IntroPrefs.shouldShow(afterSignUp: false), isTrue);
    });

    test("stays away after Don't show this again", () async {
      SharedPreferences.setMockInitialValues({});
      await IntroPrefs.markSeen();
      await IntroPrefs.hideForGood();
      expect(await IntroPrefs.shouldShow(afterSignUp: false), isFalse);
      expect(await IntroPrefs.shouldShow(afterSignUp: true), isFalse);
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
