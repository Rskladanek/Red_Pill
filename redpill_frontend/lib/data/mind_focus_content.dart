// lib/data/mind_focus_content.dart

/// Statyczny content dla modułu MIND / Focus.
/// Możesz to podpiąć zamiast backendu dla MIND/FOCUS
/// albo jako fallback, gdy API nic nie zwróci.

class FocusLesson {
  final int order;
  final String title;
  final String text;

  const FocusLesson({
    required this.order,
    required this.title,
    required this.text,
  });
}

class FocusTask {
  final int order;
  final String title;
  final String body;
  final String difficulty; // "easy" | "medium" | "hard" (możesz olać)
  final List<String> checklist;

  const FocusTask({
    required this.order,
    required this.title,
    required this.body,
    required this.difficulty,
    required this.checklist,
  });
}

class FocusQuizQuestion {
  final int order;
  final String question;
  final List<String> options;
  final int correctIndex;

  const FocusQuizQuestion({
    required this.order,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class FocusContent {
  static const String track = 'mind';
  static const String module = 'Focus';

  /// LEKCJE – tekst “dla normalnego człowieka”
  static final List<FocusLesson> lessons = [
    FocusLesson(
      order: 1,
      title: 'Fokus 1: Co to jest skupienie i po co ci głęboka praca',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja w prosty sposób tłumaczy, co to jest fokus (skupienie) i o co chodzi z tak zwaną "głęboką pracą".
Zanim cokolwiek poprawisz, musisz zrozumieć, CO w ogóle chcesz trenować.

CO TO JEST FOKUS

- Fokus to umiejętność trzymania uwagi na JEDNEJ rzeczy przez dłuższy czas.
- Nie chodzi o samo siedzenie przy komputerze, tylko o PRAWDZIWĄ pracę nad konkretnym zadaniem.
- Jeśli co 2–3 minuty zmieniasz okno, aplikację albo patrzysz w telefon – to nie jest fokus, tylko chaos.

Przykład:
Siedzisz niby nad projektem, ale:
- 5 minut kod,
- potem Messenger,
- potem mail,
- potem YouTube "na chwilę",
- potem TikTok / Reels / coś tam.
Na koniec jesteś zmęczony, ale nie wiesz, co właściwie zrobiłeś. To właśnie brak fokusa.

CO TO JEST GŁĘBOKA PRACA

- Głęboka praca to blok czasu (np. 25–60 minut), gdzie robisz coś trudnego i ważnego:
  kod, nauka, pisanie, analiza, planowanie.
- W tym czasie NIE:
  - sprawdzasz powiadomień,
  - nie scrollujesz,
  - nie odpisujesz na wiadomości.
- Jesteś “w jednym tunelu” – z tym zadaniem, aż skończy się blok.

Przykład:
1 blok = 45 minut. W tym czasie:
- tylko IDE / edytor,
- tylko ten projekt / zadanie,
- zero telefonu, zero przeskakiwania po zakładkach.
Po takim bloku faktycznie widać postęp.

DLACZEGO TO JEST WAŻNE

- Najważniejsze rzeczy w życiu (projekty, biznes, nauka, zmiana siebie) powstają w GŁĘBOKIEJ PRACY,
  a nie w ciągłym “dłubaniu” między powiadomieniami.
- Bez fokusa możesz:
  - być wiecznie zajęty,
  - mieć wrażenie, że ciężko pracujesz,
  - ale realnie nic dużego nie dowozisz.
- Fokus to NIE talent. To mięsień. Da się go trenować małymi krokami, tak jak siłownię.

PODSUMOWANIE W 3 ZDANIACH

1) Fokus = robisz jedną rzecz naraz, a nie skaczesz po 10.
2) Głęboka praca = trudne zadanie + blok czasu + zero rozpraszaczy.
3) Jak nie pilnujesz swojej uwagi, zrobi to za ciebie telefon, internet i inni ludzie.
''',
    ),
    FocusLesson(
      order: 2,
      title: 'Fokus 2: Najwięksi wrogowie twojej koncentracji',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja pokazuje, CO rozwala ci koncentrację na co dzień.
Nie po to, żebyś się biczował, tylko po to, żebyś widział, z czym naprawdę walczysz.

TRZY GŁÓWNE PROBLEMY

1) KRÓTKA DOPAMINA

- Krótka dopamina to szybkie małe przyjemności:
  scroll, memy, krótkie filmiki, powiadomienia, powrót do messengera “na sekundę”.
- Mózg to kocha, bo nagroda jest NATYCHMIAST:
  nic trudnego, po prostu klik i przyjemność.
- Głęboka praca jest odwrotna:
  jest trudniej, a nagroda (wynik, postęp, efekty) jest później.

Efekt:
- Zaczynasz trudne zadanie.
- Pojawia się dyskomfort ("nie wiem", "nie wychodzi", "nudne").
- Mózg podpowiada: “sprawdź coś” → telefon → social media → filmik.
- I tak w kółko.

2) MULTITASKING (robienie kilku rzeczy naraz)

- Mózg nie robi kilku trudnych rzeczy jednocześnie, tylko bardzo szybko SKACZE między nimi.
- Każda zmiana zadania = koszt:
  - musisz sobie przypomnieć, gdzie byłeś,
  - wkręcić się z powrotem w kontekst.
- Po takim dniu:
  - czujesz się zmęczony,
  - ale realnie niewiele ważnego zostało dowiezione.

3) MIKRO-PRZERWY

- Mikro-przerwa to:
  "tylko sprawdzę na sekundę",
  "tylko zobaczę, co tam na Instagramie / TikToku / YouTube".
- Problem: te "sekundy" zamieniają się w minuty, a ty wypadasz z rytmu.
- Po powrocie do zadania musisz się znowu rozpędzać.

DLACZEGO TO WAŻNE

- Nie jesteś “zepsuty”, jeśli odpływasz w scroll.
- Po prostu grasz przeciwko systemom (apki, social media), które są zaprojektowane, żeby
  WYGRYWAĆ z twoją uwagą.
- Jak wiesz, co cię rozwala, możesz zacząć to krok po kroku ograniczać.

PODSUMOWANIE W 3 ZDANIACH

1) Twój mózg automatycznie wybiera łatwe przyjemności zamiast trudnych zadań.
2) Multitasking i mikro-przerwy powoli zabijają twoją koncentrację.
3) Pierwszy krok to zobaczyć te wzorce u siebie – bez ściemy.
''',
    ),
    FocusLesson(
      order: 3,
      title: 'Fokus 3: Jedna najważniejsza rzecz dziennie',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja uczy, jak ustawić dzień tak, żeby naprawdę coś ruszyć,
zamiast tylko gasić pożary i odhaczać pierdoły.

DLACZEGO JEDNA NAJWAŻNIEJSZA RZECZ

- Kiedy widzisz listę 20 zadań, mózg:
  - gubi się,
  - nie wie, od czego zacząć,
  - wybiera zwykle to, co najłatwiejsze albo najmniej bolesne.
- W efekcie często:
  - robisz rzeczy pilne, ale mało ważne,
  - odkładasz to, co naprawdę miałoby sens.

Jedna najważniejsza rzecz (tzw. ONE THING) to:
- jedno zadanie,
- które, jeśli zrobisz,
- sprawi, że dzień jest wygrany, nawet jeśli reszta pójdzie średnio.

JAK WYBRAĆ TO JEDNO ZADANIE

Zadaj sobie pytanie:

"Gdyby dziś udało mi się zrobić tylko JEDNĄ rzecz,
która naprawdę przesunie mnie do przodu – co to by było?"

Przykłady:
- Ukończenie ważnej części projektu.
- Nauczenie się konkretnej partii materiału.
- Napisanie ważnego maila, który odwlekasz już tydzień.
- Zrobienie porządnego planu / strategii na coś większego.

KIEDY PLANOWAĆ

- Najlepiej wieczorem poprzedniego dnia.
- Rano nie wymyślasz na nowo – patrzysz na to, co już ustaliłeś.
- Rano jesteś bardziej “wykonawcą”, a mniej “strategiem”.

PODSUMOWANIE W 3 ZDANIACH

1) Każdy dzień powinien mieć JEDNO główne zadanie, które naprawdę się liczy.
2) Wybierasz je wieczorem, żeby rano nie wejść od razu w chaos.
3) Lepiej dowieźć jedną ważną rzecz niż 10 małych głupotek.
''',
    ),
    FocusLesson(
      order: 4,
      title: 'Fokus 4: Bloki pracy zamiast ciągłego dłubania',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja pokazuje prosty sposób organizacji czasu:
robienie rzeczy w blokach, a nie "kiedy wyjdzie".

CO TO JEST BLOK PRACY

- Blok pracy to odcinek czasu, który z góry ustalasz, np.:
  - 25 minut,
  - 45 minut,
  - 60 minut.
- W tym czasie robisz tylko JEDNO wcześniej wybrane zadanie.

W bloku pracy:
- nie sprawdzasz powiadomień,
- nie odpisujesz ludziom,
- nie przeskakujesz między 10 rzeczami.

DLACZEGO TO DZIAŁA

- Mózg lubi mieć ramy: “pracujemy przez X minut, potem przerwa”.
- Łatwiej wytrzymać 25–45 minut konkretnej roboty, niż rozmyślne “muszę pracować cały dzień”.
- Kilka dobrych bloków dziennie daje ogromny efekt, nawet jeśli łącznie to tylko 2–3 godziny
  czystej roboty.

JAK DOBRAĆ DŁUGOŚĆ BLOKU

- Start:
  - 25 minut pracy + 5 minut przerwy.
- Potem możesz przejść do:
  - 45 minut pracy + 10–15 minut przerwy.
- Nie chodzi o idealne liczby – chodzi o to, że w tym czasie jesteś przy JEDNYM zadaniu.

JAK ROBIĆ PRZERWY

- Przerwa NIE jest do nadrabiania social mediów.
- Przerwa jest po to, żeby odetchnąć:
  - wstań,
  - przejdź się,
  - napij się wody,
  - przewietrz pokój,
  - popatrz w dal (nie w ekran).
- Po przerwie – kolejny blok albo koniec pracy, jeśli tyle zaplanowałeś.

PODSUMOWANIE W 3 ZDANIACH

1) Blok pracy = jeden odcinek czasu na jedno zadanie.
2) Kilka bloków dziennie to już bardzo dużo, jeśli są zrobione naprawdę.
3) Przerwy mają odświeżać, a nie wciągać w scroll.
''',
    ),
    FocusLesson(
      order: 5,
      title: 'Fokus 5: Telefon pod kontrolą',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja mówi wprost: telefon to jedno z głównych narzędzi, które rozwalają ci fokus.
Nie chodzi o to, żebyś wyrzucał telefon. Chodzi o to, żebyś przestał być jego niewolnikiem.

DLACZEGO TELEFON TAK MOCNO CIĘ ROZPRASZA

- Telefon jest zawsze przy tobie.
- Jest pełen aplikacji, które walczą o twoją uwagę:
  social media, komunikatory, gry, powiadomienia.
- Każde "piknięcie", ikonka, czerwony badge wywołuje:
  ciekawość, FOMO, nawyk “muszę sprawdzić”.

Efekt:
- Zaczynasz pracę,
- pierwsze trudniejsze miejsce → odruchowo łapiesz za telefon.
- Mózg uczy się: "jak coś niewygodne → biorę telefon → dostaję małą nagrodę".

NAJGORSZE NAWYKI

- Telefon leży ekranem do góry obok klawiatury.
- Powiadomienia włączone na wszystko (Messenger, Insta, TikTok, mail itp.).
- Scrollowanie jeszcze zanim zaczniesz pracę (zabijasz fokus na starcie).

CO ZROBIĆ, ŻEBY BYŁO LEPIEJ

1) TELEFON DALEJ OD RĘKI
- Najprostsze i najskuteczniejsze:
  - podczas bloku pracy odłóż telefon do innego pokoju,
  - albo przynajmniej do plecaka / szuflady.
- Ważne: nie widzisz go kątem oka.

2) POWIADOMIENIA
- Zostaw tylko:
  - telefony od najważniejszych osób (rodzina, partner, coś naprawdę krytycznego).
- Wyłącz:
  - powiadomienia z social mediów,
  - powiadomienia z gier,
  - większość komunikatorów (sprawdzisz je PO bloku pracy).

PODSUMOWANIE W 3 ZDANIACH

1) Telefon jest zaprojektowany, żeby wygrywać z twoją uwagą.
2) Podczas pracy najlepiej trzymać go fizycznie daleko.
3) Powiadomienia zrób pod siebie – większość z nich może spokojnie poczekać.
''',
    ),
    FocusLesson(
      order: 6,
      title: 'Fokus 6: Twoje otoczenie – biurko, dźwięk, ludzie',
      text: '''
PO CO JEST TA LEKCJA

Ta lekcja pokazuje, że fokus to nie tylko “silna wola w głowie”.
To też to, co masz DOOKOŁA: biurko, dźwięki, ludzi.

BIURKO

- Biurko zawalone rzeczami to ciągłe mikro-przypomnienia:
  "tu jest książka", "tu jest paragon", "tu jest notatka, którą miałem przeczytać".
- Mózg widzi to cały czas, nawet jeśli nie zwracasz na to uwagi świadomie.
- Im mniej śmieci na biurku, tym łatwiej skupić się na tym jednym zadaniu.

Prosty standard:
- Na biurku podczas pracy:
  - komputer / monitor,
  - notatnik + długopis,
  - szklanka / butelka z wodą,
  - ewentualnie jedna rzecz związana z zadaniem (np. książka, jeśli z niej korzystasz).
- Reszta może być w szufladzie, na półce, gdzie indziej.

DŹWIĘK

- Ciągły hałas, rozmowy, tv w tle – to cały czas wyciąga uwagę.
- Dla wielu osób najlepiej działa:
  - cisza,
  - biały szum (np. deszcz, wiatr),
  - spokojna muzyka bez tekstu.
- Tekst w muzyce często miesza się z tym, co masz na ekranie – mózg próbuje czytać jedno i drugie.

LUDZIE

- Jeśli pracujesz z innymi w jednym pokoju / open space:
  - “masz chwilę?”, “tylko jedno pytanie” – potrafi rozwalić ci każdy blok pracy.
- Potrzebujesz choć jednego bloku w ciągu dnia, kiedy:
  - ustawiasz sobie czas,
  - mówisz wprost: “przez następne 45 minut pracuję, wrócę później”.

PODSUMOWANIE W 3 ZDANIACH

1) Bałagan na biurku, hałas i ciągłe zaczepki ludzi zjadają fokus po cichu.
2) Możesz to poprawić bardzo prostymi krokami: czystsze biurko, słuchawki, jasne zasady z ludźmi.
3) Nie czekaj na idealne warunki – popraw to, co możesz, już dzisiaj.
''',
    ),
  ];

  /// TASKI – zadania do zrobienia w realu
  static final List<FocusTask> tasks = [
    FocusTask(
      order: 1,
      title: 'Zadania do lekcji 1: Co to jest fokus',
      body:
          'Dzisiaj zaczniesz świadomie patrzeć na to, jak pracujesz. Proste kroki, bez filozofii.',
      difficulty: 'easy',
      checklist: [
        'Zapisz na kartce: "Moje najważniejsze zadanie na dziś to: ________". Wpisz tam JEDNO konkretne zadanie.',
        'Połóż tę kartkę w miejscu, które widzisz podczas pracy (np. obok monitora).',
        'Przez 30 minut obserwuj, ile razy automatycznie sięgasz po telefon lub klikasz coś niezwiązanego z zadaniem. Nie oceniaj – po prostu licz.',
      ],
    ),
    FocusTask(
      order: 2,
      title: 'Zadania do lekcji 2: Wrogowie fokusa',
      body: 'Złap swoje największe rozpraszacze na gorącym uczynku.',
      difficulty: 'easy',
      checklist: [
        'Wypisz 5 rzeczy, które NAJCZĘŚCIEJ cię rozpraszają (konkretnie: nazwa aplikacji, strony, zachowania).',
        'Podczas jednej godziny pracy rób kreskę na kartce za każdym razem, gdy zmienisz okno / zadanie bez potrzeby.',
        'Na koniec tej godziny napisz jednym zdaniem: "Najczęściej rozprasza mnie: ________".',
      ],
    ),
    FocusTask(
      order: 3,
      title: 'Zadania do lekcji 3: Jedna rzecz dziennie',
      body: 'Ustaw swój jutrzejszy dzień tak, żeby miał jeden jasny priorytet.',
      difficulty: 'medium',
      checklist: [
        'Wieczorem wybierz jedną najważniejszą rzecz na jutro. Zapisz: "Jeśli zrobię tylko to, dzień i tak będzie wygrany: ________".',
        'Dodaj maksymalnie 3 mniejsze zadania wspierające (rzeczy, które pomogą w głównym celu).',
        'Połóż tę kartkę tam, gdzie zobaczysz ją jako pierwszą po otwarciu laptopa jutro.',
      ],
    ),
    FocusTask(
      order: 4,
      title: 'Zadania do lekcji 4: Bloki pracy',
      body: 'Przetestuj blok skupionej pracy na prawdziwym zadaniu.',
      difficulty: 'medium',
      checklist: [
        'Wybierz jedno zadanie, które dziś chcesz ruszyć (nauka, projekt, praca).',
        'Ustaw timer na 25 minut i pracuj tylko nad TYM zadaniem. Bez social media, bez messengera, bez nowych zakładek.',
        'Po bloku zrób minimum 5 minut przerwy bez telefonu (przejdź się, rozciągnij się, napij się wody).',
      ],
    ),
    FocusTask(
      order: 5,
      title: 'Zadania do lekcji 5: Telefon',
      body: 'Sprawdź, jak wygląda twoja praca bez telefonu obok.',
      difficulty: 'medium',
      checklist: [
        'Na najbliższy blok pracy odłóż telefon do innego pokoju lub przynajmniej do szuflady, ekranem w dół.',
        'Wyłącz powiadomienia z social mediów i komunikatorów na minimum 2 godziny (zostaw tylko połączenia).',
        'Po zakończeniu pracy napisz jednym zdaniem, czy było ci łatwiej się skupić, gdy telefon nie leżał obok.',
      ],
    ),
    FocusTask(
      order: 6,
      title: 'Zadania do lekcji 6: Otoczenie',
      body: 'Ustaw swoje otoczenie tak, żeby pomagało, a nie przeszkadzało.',
      difficulty: 'medium',
      checklist: [
        'Posprzątaj biurko tak, żeby zostały na nim tylko: komputer, notatnik, długopis i napój.',
        'Zrób jeden blok pracy w słuchawkach (cisza, biały szum, muzyka bez tekstu), jeśli masz hałaśliwe otoczenie.',
        'Jeśli pracujesz z innymi: powiedz im, że przez następne 30–45 minut chcesz pracować w skupieniu i wrócisz do nich później.',
      ],
    ),
  ];

  /// QUIZ – proste pytania, 1 poprawna odpowiedź
  static final List<FocusQuizQuestion> quiz = [
    FocusQuizQuestion(
      order: 1,
      question: 'Co w tym kursie rozumiemy jako "fokus"?',
      options: [
        'Robienie wielu rzeczy naraz i bycie cały czas zajętym',
        'Zdolność trzymania uwagi na jednym zadaniu przez dłuższy czas',
        'Pracę tylko wtedy, kiedy masz ochotę',
        'Siedzenie długo przy komputerze, nieważne co robisz',
      ],
      correctIndex: 1,
    ),
    FocusQuizQuestion(
      order: 2,
      question: 'Czym różni się głęboka praca od zwykłego "dłubania"?',
      options: [
        'W głębokiej pracy robisz tylko proste i przyjemne zadania',
        'W głębokiej pracy co chwilę sprawdzasz telefon',
        'W głębokiej pracy robisz trudne zadanie bez rozpraszaczy przez dłuższy czas',
        'To to samo, tylko inaczej nazwane',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 3,
      question: 'Dlaczego multitasking szkodzi twojej koncentracji?',
      options: [
        'Bo multitasking jest tylko dla bardzo mądrych ludzi',
        'Bo przy multitaskingu ciągle zmieniasz zadanie i tracisz energię na powroty do poprzedniego',
        'Bo multitasking wymaga drogiego sprzętu',
        'Bo multitasking jest zakazany w większości firm',
      ],
      correctIndex: 1,
    ),
    FocusQuizQuestion(
      order: 4,
      question: 'Co to jest "mikro-przerwa" w kontekście fokusa?',
      options: [
        'Krótka przerwa na wodę lub toaletę',
        'Krótka drzemka 20 minut',
        'Szybkie sięgnięcie po telefon lub sprawdzenie czegoś w trakcie zadania',
        'Pełna przerwa obiadowa',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 5,
      question: 'Po co wybierać JEDNO najważniejsze zadanie na dzień?',
      options: [
        'Żeby mieć wymówkę, żeby nie robić innych rzeczy',
        'Żeby móc się pochwalić w social mediach',
        'Żeby mózg wiedział, co jest priorytetem, a nie tonął w 20 zadaniach naraz',
        'Żeby szybciej skończyć dzień',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 6,
      question: 'Kiedy najlepiej planować najważniejsze zadanie na kolejny dzień?',
      options: [
        'Rano, tuż po przebudzeniu',
        'W trakcie dnia, kiedy ci się przypomni',
        'Wieczorem, przed końcem dnia',
        'Lepiej wcale, spontaniczność jest ważniejsza',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 7,
      question: 'Jak wygląda dobrze zrobiony blok pracy?',
      options: [
        'Co chwilę przerywasz, żeby sprawdzić wiadomości',
        'Masz otwartych dużo zadań i skaczesz między nimi',
        'Przez określony czas robisz jedno zadanie, bez rozpraszaczy',
        'Cały czas myślisz tylko o tym, kiedy będzie przerwa',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 8,
      question: 'Co jest najważniejsze podczas przerwy między blokami pracy?',
      options: [
        'Żeby nadrobić social media',
        'Żeby odpisać na wszystkie maile',
        'Żeby dać głowie chwilę oddechu i NIE wchodzić od razu w scroll',
        'Żeby zacząć nowe trudne zadanie',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 9,
      question: 'Dlaczego telefon na biurku to słaby pomysł podczas pracy?',
      options: [
        'Bo zajmuje miejsce na biurku',
        'Bo może się rozładować',
        'Bo sam widok telefonu i każde powiadomienie ciągną twoją uwagę',
        'Bo telefon jest "nieprofesjonalny"',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 10,
      question:
          'Jakie proste rozwiązanie najlepiej pomaga ograniczyć wpływ telefonu na fokus?',
      options: [
        'Zmiana tapety na mniej kolorową',
        'Trzymanie telefonu w ręce, żeby mieć go pod kontrolą',
        'Odkładanie telefonu do innego pokoju na czas bloku pracy',
        'Odinstalowanie wszystkich aplikacji',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 11,
      question: 'Dlaczego bałagan na biurku szkodzi koncentracji?',
      options: [
        'Bo źle wygląda na zdjęciach',
        'Bo trudniej coś znaleźć',
        'Bo każdy przedmiot to dodatkowy bodziec, który zajmuje kawałek uwagi',
        'Bo tak mówią poradniki',
      ],
      correctIndex: 2,
    ),
    FocusQuizQuestion(
      order: 12,
      question:
          'Jak możesz w prosty sposób zmniejszyć hałas, który przeszkadza ci w pracy?',
      options: [
        'Włączyć radio z głośną muzyką',
        'Założyć słuchawki i puścić cichy szum lub muzykę bez tekstu',
        'Częściej sprawdzać, co się dzieje wokół',
        'Przenieść się do kuchni',
      ],
      correctIndex: 1,
    ),
  ];
}

