import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/repositories/bookmarks_repository.dart';
import 'package:kubenav/repositories/clusters_repository.dart';
import 'package:kubenav/repositories/theme_repository.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/helpers.dart';
import 'package:kubenav/utils/navigate.dart';
import 'package:kubenav/utils/showmodal.dart';
import 'package:kubenav/widgets/resources/bookmarks/resources_bookmark_actions.dart';
import 'package:kubenav/widgets/resources/resource_details.dart';
import 'package:kubenav/widgets/resources/resources_list.dart';
import 'package:kubenav/widgets/shared/app_bottom_navigation_bar_widget.dart';
import 'package:kubenav/widgets/shared/app_floating_action_buttons_widget.dart';

/// The [ResourcesBookmarks] widget can be used as a screen to view all
/// bookmarks saved by a user. When the user then clicks on a bookmark he will
/// be redirected to the corresponding resource. When the user double clicks on
/// the bookmark an actions menu will be shown which can be used to delete the
/// bookmark.
class ResourcesBookmarks extends StatefulWidget {
  const ResourcesBookmarks({Key? key}) : super(key: key);

  @override
  State<ResourcesBookmarks> createState() => _ResourcesBookmarksState();
}

class _ResourcesBookmarksState extends State<ResourcesBookmarks> {
  /// [_proxyDecorator] is used to highlight the bookmark which is currently
  /// draged by the user.
  Widget _proxyDecorator(BuildContext context, Widget child, int index,
      Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          shadowColor: theme(context).colorShadow,
          child: child,
        );
      },
      child: child,
    );
  }

  /// [openBookmark] redirects the user to the bookmark with the provided
  /// [index]. Before the user is redirected to the resource page, we have to
  /// change the active cluster and namespace to the values saved in the
  /// bookmark. Then we open the [ResourcesList] or [ResourcesDetails] widget
  /// with the bookmark values as arguments.
  Future<void> openBookmark(BuildContext context, int index) async {
    ClustersRepository clustersRepository = Provider.of<ClustersRepository>(
      context,
      listen: false,
    );
    BookmarksRepository bookmarksRepository = Provider.of<BookmarksRepository>(
      context,
      listen: false,
    );

    try {
      if (bookmarksRepository.bookmarks[index].type == BookmarkType.list) {
        await clustersRepository
            .setActiveCluster(bookmarksRepository.bookmarks[index].clusterId);
        await clustersRepository.setNamespace(
            bookmarksRepository.bookmarks[index].clusterId,
            bookmarksRepository.bookmarks[index].namespace ?? '');

        if (mounted) {
          navigate(
            context,
            ResourcesList(
              title: bookmarksRepository.bookmarks[index].title,
              resource: bookmarksRepository.bookmarks[index].resource,
              path: bookmarksRepository.bookmarks[index].path,
              scope: bookmarksRepository.bookmarks[index].scope,
              additionalPrinterColumns:
                  bookmarksRepository.bookmarks[index].additionalPrinterColumns,
              namespace: bookmarksRepository.bookmarks[index].namespace,
              selector: null,
            ),
          );
        }
      } else if (bookmarksRepository.bookmarks[index].type ==
          BookmarkType.details) {
        if (bookmarksRepository.bookmarks[index].name == null) {
          throw Exception('Invalid Bookmark');
        }

        await clustersRepository
            .setActiveCluster(bookmarksRepository.bookmarks[index].clusterId);
        await clustersRepository.setNamespace(
            bookmarksRepository.bookmarks[index].clusterId,
            bookmarksRepository.bookmarks[index].namespace ?? '');

        if (mounted) {
          navigate(
            context,
            ResourcesDetails(
              title: bookmarksRepository.bookmarks[index].title,
              resource: bookmarksRepository.bookmarks[index].resource,
              path: bookmarksRepository.bookmarks[index].path,
              scope: bookmarksRepository.bookmarks[index].scope,
              additionalPrinterColumns:
                  bookmarksRepository.bookmarks[index].additionalPrinterColumns,
              name: bookmarksRepository.bookmarks[index].name!,
              namespace: bookmarksRepository.bookmarks[index].namespace,
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeRepository>(
      context,
      listen: true,
    );
    BookmarksRepository bookmarksRepository = Provider.of<BookmarksRepository>(
      context,
      listen: true,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bookmarks'),
      ),
      bottomNavigationBar: const AppBottomNavigationBarWidget(),
      floatingActionButton: const AppFloatingActionButtonsWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: Constants.spacingLarge),
            ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                right: Constants.spacingMiddle,
                left: Constants.spacingMiddle,
              ),
              onReorder: (int start, int current) {
                bookmarksRepository.reorder(start, current);
              },
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) =>
                      _proxyDecorator(context, child, index, animation),
              itemCount: bookmarksRepository.bookmarks.length,
              itemBuilder: (
                context,
                index,
              ) {
                return ReorderableDragStartListener(
                  key: Key(
                    '${bookmarksRepository.bookmarks[index].type} ${bookmarksRepository.bookmarks[index].clusterId} ${bookmarksRepository.bookmarks[index].title} ${bookmarksRepository.bookmarks[index].resource} ${bookmarksRepository.bookmarks[index].path} ${bookmarksRepository.bookmarks[index].scope} ${bookmarksRepository.bookmarks[index].name} ${bookmarksRepository.bookmarks[index].namespace}',
                  ),
                  index: index,
                  child: Container(
                    key: Key(
                      '${bookmarksRepository.bookmarks[index].type} ${bookmarksRepository.bookmarks[index].clusterId} ${bookmarksRepository.bookmarks[index].title} ${bookmarksRepository.bookmarks[index].resource} ${bookmarksRepository.bookmarks[index].path} ${bookmarksRepository.bookmarks[index].scope} ${bookmarksRepository.bookmarks[index].name} ${bookmarksRepository.bookmarks[index].namespace}',
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: Constants.spacingMiddle,
                      ),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: theme(context).colorShadow,
                            blurRadius: Constants.sizeBorderBlurRadius,
                            spreadRadius: Constants.sizeBorderSpreadRadius,
                            offset: const Offset(0.0, 0.0),
                          ),
                        ],
                        color: theme(context).colorCard,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(Constants.sizeBorderRadius),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          openBookmark(context, index);
                        },
                        onDoubleTap: () {
                          showActions(
                            context,
                            ResourcesBookmarkActions(
                              index: index,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookmarksRepository
                                            .bookmarks[index].title,
                                        style: primaryTextStyle(
                                          context,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Characters(
                                              'Cluster: ${bookmarksRepository.bookmarks[index].clusterId}',
                                            )
                                                .replaceAll(Characters(''),
                                                    Characters('\u{200B}'))
                                                .toString(),
                                            style: secondaryTextStyle(
                                              context,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            Characters(
                                              'Namespace: ${bookmarksRepository.bookmarks[index].namespace}',
                                            )
                                                .replaceAll(Characters(''),
                                                    Characters('\u{200B}'))
                                                .toString(),
                                            style: secondaryTextStyle(
                                              context,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          bookmarksRepository
                                                      .bookmarks[index].name !=
                                                  null
                                              ? Text(
                                                  Characters(
                                                    'Name: ${bookmarksRepository.bookmarks[index].name}',
                                                  )
                                                      .replaceAll(
                                                          Characters(''),
                                                          Characters(
                                                              '\u{200B}'))
                                                      .toString(),
                                                  style: secondaryTextStyle(
                                                    context,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : Container(),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey[300],
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: Constants.spacingSmall),
          ],
        ),
      ),
    );
  }
}