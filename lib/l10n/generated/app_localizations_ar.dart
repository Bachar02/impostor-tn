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
  String get actionChangeSetup => 'بدّل اللاعبين والباكوات';

  @override
  String get actionHome => 'الرئيسية';

  @override
  String get stateRestoreFailed => 'الطرح اللي فات ما نجّمناش نرجّعوه';

  @override
  String get handoffPassLabel => 'أعطي التليفون لـ';

  @override
  String get revealRoleLabelSealed => 'دور';

  @override
  String get playersMaxReached => '12 لاعب هو الحدّ';

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
      'كل لاعب ياخذ التليفون، يشوف دورو وحدو، يخبّيه، ومبعد يعدّيه.';

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

  @override
  String get roleImpostor => 'إمبوستور';

  @override
  String get roleCivilian => 'مدني';

  @override
  String get playersTitle => 'اللاعبين';

  @override
  String get playersNameLimit => 'حتى 16 حرف';

  @override
  String packWordCount(String n) {
    return '$n كلمة';
  }

  @override
  String get revealRoleLabel => 'دورك';

  @override
  String get revealCategoryOnly => 'الصنف برك';

  @override
  String get phaseClues => 'التلميحات';

  @override
  String get phaseVote => 'التصويت';

  @override
  String get voteSelf => 'إنتي';

  @override
  String get homeNewGame => 'طرح جديد';

  @override
  String get homeTagline => 'شكون فيكم؟';

  @override
  String get playersAdd => 'زيد لاعب';

  @override
  String get playersNameLabel => 'اسم اللاعب';

  @override
  String get playersNameHint => 'مثلا: سلمى';

  @override
  String get playersEmpty => 'مازال ما فمّا حتى لاعب';

  @override
  String get playersEmptyHint => 'زيد 3 لاعبين باش تبداو';

  @override
  String get errorNameDuplicate => 'الاسم هذا موجود';

  @override
  String get errorNameEmpty => 'اكتب اسم';

  @override
  String get errorMinPlayers => 'لازمكم 3 لاعبين على الأقل';

  @override
  String get packSelected => 'مختار';

  @override
  String get packEmpty => 'ما فيه حتى كلمة';

  @override
  String get actionStart => 'هيّا نبداو';

  @override
  String get actionConfirm => 'أكّد';

  @override
  String get actionBack => 'ارجع';

  @override
  String get actionDeletePlayer => 'فسّخ اللاعب';

  @override
  String get actionRename => 'بدّل الاسم';

  @override
  String get actionRetry => 'عاود';

  @override
  String get actionPlayAgain => 'طرح آخر';

  @override
  String handoffPassTo(String name) {
    return 'أعطي التليفون لـ $name';
  }

  @override
  String handoffIAm(String name) {
    return 'أنا $name';
  }

  @override
  String get privacyOnlyYou => 'ما يشوف حد غيرك';

  @override
  String get revealSealed => 'الدور مخبّي';

  @override
  String get revealShow => 'ورّيني دوري';

  @override
  String get revealWordLabel => 'الكلمة السرّية';

  @override
  String revealCategory(String category) {
    return 'الصنف: $category';
  }

  @override
  String get revealNoWord => 'ما تعرفش الكلمة';

  @override
  String get revealAck => 'فهمت، خبّي';

  @override
  String get revealAllDone => 'الكل شافوا دورهم';

  @override
  String get voteTie => 'تعادل في الأصوات. نعاودو التصويت بيناتهم.';

  @override
  String get resultCiviliansWin => 'المدنيين ربحوا';

  @override
  String get resultImpostorWins => 'الإمبوستور ربح';

  @override
  String get resultDraw => 'تعادل';

  @override
  String get dialogQuitTitle => 'تخرج من الطرح؟';

  @override
  String get dialogQuitBody => 'الطرح الحالي يتفسّخ وما تنجّمش ترجّعو.';

  @override
  String get dialogQuitConfirm => 'أخرج';

  @override
  String get dialogQuitCancel => 'كمّل اللعب';

  @override
  String get stateLoading => 'لحظة…';

  @override
  String get stateResumed => 'الطرح توقّف. كمّلوا من وين وصلتوا.';

  @override
  String get stateError => 'صار مشكل. عاود مرّة أخرى.';

  @override
  String dialogDeletePlayerTitle(String name) {
    return 'تفسّخ $name؟';
  }

  @override
  String get dialogDeletePlayerBody => 'الاسم يتنحّى من الليستة.';

  @override
  String get dialogDeletePlayerCancel => 'خلّيه';
}
