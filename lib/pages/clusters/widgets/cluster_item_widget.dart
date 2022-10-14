import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:kubenav/models/cluster_model.dart';
import 'package:kubenav/models/provider_model.dart';
import 'package:kubenav/services/kubernetes_service.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/helpers.dart';
import 'package:kubenav/utils/logger.dart';

class ClusterItemController extends GetxController {
  Cluster cluster;
  RxBool statusOk = false.obs;

  ClusterItemController({required this.cluster});

  @override
  void onInit() {
    getClusterStatus();
    super.onInit();
  }

  /// [getClusterStatus] makes an request against the Kubernetes api of the given cluster. If the request returns a
  /// status code >= 200 and < 300 we set the [statusOk] variable to `true`. If the request fails with another status
  /// code, we set the [statusOk] variable to `false`.
  void getClusterStatus() async {
    try {
      final result = await KubernetesService(cluster: cluster).checkHealth();
      Logger.log(
        'ClusterItemController getClusterStatus',
        'Cluster status was returned successfully',
        result,
      );
      statusOk.value = result;
    } catch (err) {
      Logger.log(
        'ClusterItemController getClusterStatus',
        'There was an error while returning the cluster status',
        err,
      );
      statusOk.value = false;
    }
  }
}

class ClusterItemWidget extends StatelessWidget {
  const ClusterItemWidget({
    Key? key,
    required this.cluster,
    required this.isActiveCluster,
    this.provider,
    this.onTap,
    this.onDoubleTap,
  }) : super(key: key);

  final Cluster cluster;
  final bool isActiveCluster;
  final Provider? provider;
  final void Function()? onTap;
  final void Function()? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    ClusterItemController controller = Get.put(
      ClusterItemController(cluster: cluster),
      tag: cluster.name,
    );

    return Obx(
      () {
        return Container(
          margin: const EdgeInsets.only(
            bottom: Constants.spacingMiddle,
          ),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: Constants.sizeBorderBlurRadius,
                spreadRadius: Constants.sizeBorderSpreadRadius,
                offset: const Offset(0.0, 0.0),
              ),
            ],
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(Constants.sizeBorderRadius),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Characters(cluster.name)
                                .replaceAll(
                                    Characters(''), Characters('\u{200B}'))
                                .toString(),
                            style: primaryTextStyle(
                              context,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Characters(provider != null ? provider!.title : '-')
                                .replaceAll(
                                    Characters(''), Characters('\u{200B}'))
                                .toString(),
                            style: secondaryTextStyle(
                              context,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isActiveCluster
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 24,
                      color: controller.statusOk.value
                          ? Constants.colorSuccess
                          : Constants.colorDanger,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
