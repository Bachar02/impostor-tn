// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'إمبوستور';

  @override
  String get actionGotIt => 'فهمت';

  @override
  String get actionContinue => 'كمّل';

  @override
  String get actionAdd => 'زيد';

  @override
  String get actionStartVote => 'نبداو التصويت';

  @override
  String get actionSeeResult => 'شوفوا النتيجة';

  @override
  String get actionRunoffStart => 'نعاودو التصويت';

  @override
  String get actionChangeSetup => 'بدّل اللعّابة والباكوات';

  @override
  String get actionHome => 'الرئيسية';

  @override
  String get stateRestoreFailed => 'الطرح اللي فات ما نجّمناش نرجّعوه';

  @override
  String get handoffPassLabel => 'أعطي التليفون لـ';

  @override
  String get revealRoleLabelSealed => 'دور';

  @override
  String get playersMaxReached => '12 لعّاب هو الحدّ';

  @override
  String get playersMoveEarlier => 'قدّم';

  @override
  String get playersMoveLater => 'أخّر';

  @override
  String get packsTitle => 'اختار الباكوات';

  @override
  String get errorNoPack => 'اختار باكو واحد على الأقل';

  @override
  String get errorNoWords => 'ما فمّا حتى كلمة تنجّموا تلعبوا بيها';

  @override
  String get settingsCredits => 'الخطوط والأيقونات';

  @override
  String get settingsLicenses => 'التراخيص';

  @override
  String settingsVersion(String v) {
    return 'النسخة $v';
  }

  @override
  String get tutorialGoalTitle => 'الهدف';

  @override
  String get tutorialGoalBody =>
      'الكل عندهم نفس الكلمة السرّية، كان واحد: الإمبوستور. لازم تلقاوه.';

  @override
  String get tutorialRolesTitle => 'المدني والإمبوستور';

  @override
  String get tutorialRolesBody =>
      'المدني يشوف الكلمة والصنف متاعها. الإمبوستور يشوف الصنف برك.';

  @override
  String get tutorialHandoffTitle => 'تليفون واحد يدور';

  @override
  String get tutorialHandoffBody =>
      'كل لعّاب ياخذ التليفون، يشوف دورو وحدو، يخبّيه، ومبعد يعدّيه.';

  @override
  String get tutorialCluesTitle => 'تلميح بكلمة وحدة';

  @override
  String get tutorialCluesBody =>
      'كل واحد يقول كلمة وحدة على الكلمة السرّية. تنجّم تعدّي من غير ما تقول شي.';

  @override
  String get tutorialVoteTitle => 'التصويت';

  @override
  String get tutorialVoteBody =>
      'كل واحد يصوّت في السرّ على اللي يشكّ فيه، وما يصوّتش على روحو. كان فمّا تعادل، نعاودو مرّة وحدة بين المتعادلين. وكان تعاود التعادل، الطرح يوفى بتعادل.';

  @override
  String get tutorialGuessTitle => 'آخر فرصة';

  @override
  String get tutorialGuessBody =>
      'كان شدّيتو الإمبوستور، عندو محاولة وحدة باش يعرف الكلمة: كان جابها يربح، وكان غلط المدنيين يربحوا. وكان خرّجتو مدني، الإمبوستور يربح.';

  @override
  String get discussionPutPhone => 'حطّوا التليفون في الوسط';

  @override
  String get discussionRuleOneWord =>
      'كل واحد يقول كلمة وحدة على الكلمة السرّية';

  @override
  String get discussionRulePass => 'تنجّم تعدّي من غير ما تقول شي';

  @override
  String get discussionRuleThenVote => 'وقت تكمّلوا، ابداو التصويت';

  @override
  String get voteTitle => 'شكون الإمبوستور؟';

  @override
  String get voteRunoffTitle => 'التصويت الثاني';

  @override
  String get voteRunoffHint => 'اختار من بين المتعادلين';

  @override
  String get tallyTitle => 'نتيجة التصويت';

  @override
  String tallyNominated(String name) {
    return 'أكثر أصوات: $name';
  }

  @override
  String tallyImpostorCaught(String name) {
    return 'الإمبوستور: $name';
  }

  @override
  String get tallyFinalChance =>
      'آخر فرصة للإمبوستور: محاولة وحدة على الكلمة السرّية';

  @override
  String get guessTitle => 'شنوّة الكلمة السرّية؟';

  @override
  String get guessOneChance => 'محاولة وحدة برك';

  @override
  String get guessLabel => 'جوابك';

  @override
  String get guessReviewTitle => 'هذا جوابك النهائي؟';

  @override
  String get guessConfirmFinal => 'إيه، هذا جوابي';

  @override
  String get guessEdit => 'نبدّلو';

  @override
  String get resultGuessLabel => 'جواب الإمبوستور';

  @override
  String get resultGuessCorrect => 'صحيح';

  @override
  String get resultGuessWrong => 'غالط';

  @override
  String get resultVotesTitle => 'الأصوات';

  @override
  String get resultFirstBallot => 'التصويت الأوّل';

  @override
  String get resultDrawNote => 'حتى التصويت الثاني وفى بتعادل';

  @override
  String get resultCivilianOut => 'خرّجتو مدني';
}
