import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2021/models/english_today.dart';
import 'package:flutter_app_2021/packages/quote/quote.dart';
import 'package:flutter_app_2021/packages/quote/quote_model.dart';
import 'package:flutter_app_2021/pages/all_words_page.dart';
import 'package:flutter_app_2021/pages/control_page.dart';
import 'package:flutter_app_2021/values/app_assets.dart';
import 'package:flutter_app_2021/values/app_colors.dart';
import 'package:flutter_app_2021/values/app_styles.dart';
import 'package:flutter_app_2021/values/share_keys.dart';
import 'package:flutter_app_2021/widgets/app_button.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  List<EnglishToday> words = [];

  String quote = Quotes().getRandom().content!;

  List<int> fixedListRandom({int len = 1, int max = 120, int min = 1}) {
    if (len > max || len < min) {
      return [];
    }
    List<int> newList = [];

    Random random = Random();
    int count = 1;
    while (count <= len) {
      int val = random.nextInt(max);
      if (newList.contains(val)) {
        continue;
      } else {
        newList.add(val);
        count++;
      }
    }
    return newList;
  }

  getEnglishToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int len = prefs.getInt(ShareKeys.counter) ?? 5;
    List<String> newList = [];
    List<int> rans = fixedListRandom(len: len, max: nouns.length);
    for (var index in rans) {
      newList.add(nouns[index]);
    }

    setState(() {
      words = newList.map((e) => getQuote(e)).toList();
    });
  }

  EnglishToday getQuote(String noun) {
    Quote? quote;
    quote = Quotes().getByWord(noun);
    return EnglishToday(
      noun: noun,
      quote: quote?.content,
      id: quote?.id,
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _pageController = PageController(viewportFraction: 0.9);
    super.initState();
    getEnglishToday();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.secondColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondColor,
        elevation: 0,
        title: Text(
          "English today",
          style:
              AppStyles.h3.copyWith(color: AppColors.textColor, fontSize: 36),
        ),
        leading: InkWell(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Image.asset(AppAssets.menu),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              height: size.height * 1 / 10,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              child: Text(
                '"$quote"',
                style: AppStyles.h5
                    .copyWith(fontSize: 12, color: AppColors.textColor),
              ),
            ),
            SizedBox(
                height: size.height * 2 / 3,
                child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: words.length > 5 ? 6 : words.length,
                    itemBuilder: (context, index) {
                      String firstLetter =
                          words[index].noun != null ? words[index].noun! : '';
                      firstLetter = firstLetter.substring(0, 1);

                      String leftLetter =
                          words[index].noun != null ? words[index].noun! : '';
                      leftLetter = leftLetter.substring(1, leftLetter.length);

                      String quoteDefault =
                          "Think of all the beauty still left around you and be happy.";

                      String quote = words[index].quote != null
                          ? words[index].quote!
                          : quoteDefault;

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Material(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(24)),
                          color: AppColors.primaryColor,
                          elevation: 4,
                          child: InkWell(
                            onDoubleTap: () {
                              setState(() {
                                words[index].isFavorite =
                                    !words[index].isFavorite;
                              });
                            },
                            splashColor: Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: index >= 5
                                  ? InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AllWordsPage(words: words)),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          "Show more...",
                                          style: AppStyles.h3.copyWith(
                                              shadows: [
                                                const BoxShadow(
                                                    color: Colors.black26,
                                                    offset: Offset(3, 6),
                                                    blurRadius: 6)
                                              ]),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LikeButton(
                                          onTap: (bool isLiked) async {
                                            setState(() {
                                              words[index].isFavorite =
                                                  !words[index].isFavorite;
                                            });
                                            return words[index].isFavorite;
                                          },
                                          isLiked: words[index].isFavorite,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          size: 42,
                                          circleColor: const CircleColor(
                                              start: Color(0xff00ddff),
                                              end: Color(0xff0099cc)),
                                          bubblesColor: const BubblesColor(
                                            dotPrimaryColor: Color(0xff33b5e5),
                                            dotSecondaryColor:
                                                Color(0xff0099cc),
                                          ),
                                          likeBuilder: (bool isLiked) {
                                            // return Icon(
                                            //   Icons.home,
                                            //   color: isLiked
                                            //       ? Colors.deepPurpleAccent
                                            //       : Colors.grey,
                                            //   size: 42,
                                            // );
                                            return ImageIcon(
                                              const AssetImage(AppAssets.heart),
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 42,
                                            );
                                          },
                                        ),
                                        // Container(
                                        //     alignment: Alignment.centerRight,
                                        //     child: Image.asset(
                                        //       AppAssets.heart,
                                        //       color: words[index].isFavorite
                                        //           ? Colors.red
                                        //           : Colors.white,
                                        //     )),
                                        RichText(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            text: TextSpan(
                                                text: firstLetter,
                                                style: const TextStyle(
                                                    fontFamily: FontFamily.sen,
                                                    fontSize: 89,
                                                    fontWeight: FontWeight.bold,
                                                    shadows: [
                                                      BoxShadow(
                                                        color: Colors.black38,
                                                        offset: Offset(3, 6),
                                                        blurRadius: 6,
                                                      )
                                                    ]),
                                                children: [
                                                  TextSpan(
                                                    text: leftLetter,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            FontFamily.sen,
                                                        fontSize: 56,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        shadows: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black38,
                                                            offset:
                                                                Offset(3, 6),
                                                            blurRadius: 6,
                                                          )
                                                        ]),
                                                  )
                                                ])),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 24),
                                          child: AutoSizeText(
                                            '"$quote"',
                                            maxFontSize: 26,
                                            style: AppStyles.h4.copyWith(
                                                letterSpacing: 1,
                                                color: AppColors.textColor),
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      );
                    })),

            // indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: size.height * 1 / 11,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return buildIndicator(index == _currentIndex, size);
                      }),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          setState(() {
            getEnglishToday();
          });
        },
        child: Image.asset(AppAssets.exchange),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.lighBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 16),
                child: Text("Your mind",
                    style: AppStyles.h3.copyWith(
                      color: AppColors.textColor,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AppButton(label: "Favorites", onTap: () {}),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: AppButton(
                    label: "Your control",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ControlPage()));
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(bool isActive, Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: isActive ? size.width * 1 / 5 : 24,
      decoration: BoxDecoration(
          color: isActive ? AppColors.lighBlue : AppColors.lighGrey,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
          ]),
    );
  }
}
