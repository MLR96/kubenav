import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:kubenav/controllers/cluster_controller.dart';
import 'package:kubenav/controllers/portforwarding_controller.dart';
import 'package:kubenav/models/kubernetes-extensions/pod_metrics.dart';
import 'package:kubenav/models/kubernetes/io_k8s_api_core_v1_pod.dart';
import 'package:kubenav/models/prometheus_model.dart';
import 'package:kubenav/models/resource_model.dart';
import 'package:kubenav/pages/resources_details/widgets/details_containers_widget.dart';
import 'package:kubenav/pages/resources_details/widgets/details_item_widget.dart';
import 'package:kubenav/pages/resources_details/widgets/details_resources_preview_widget.dart';
import 'package:kubenav/services/kubernetes_service.dart';
import 'package:kubenav/utils/constants.dart';
import 'package:kubenav/utils/helpers.dart';
import 'package:kubenav/utils/logger.dart';
import 'package:kubenav/utils/resources/pods.dart';
import 'package:kubenav/widgets/app_prometheus_charts_widget.dart';

class PodDetailsItemController extends GetxController {
  ClusterController clusterController = Get.find();
  PortForwardingController portForwardingController = Get.find();

  final IoK8sApiCoreV1Pod? pod;
  RxBool isLoadingMetricsFinished = false.obs;
  RxList<ApisMetricsV1beta1PodMetricsItemContainer> metrics =
      <ApisMetricsV1beta1PodMetricsItemContainer>[].obs;

  PodDetailsItemController({
    required this.pod,
  });

  @override
  void onInit() {
    getMetrics();

    super.onInit();
  }

  /// [portForward] forwards the given port of a container to a local port, so that a user can connects to the container
  /// port.
  void portForward(
    String name,
    String namespace,
    String container,
    int port,
  ) async {
    try {
      snackbar(
        'Port forwarding',
        'Session is created ...',
      );

      final cluster = clusterController
          .clusters[clusterController.activeClusterIndex.value].value;

      final isStarted = await KubernetesService(cluster: cluster).startServer();
      if (isStarted) {
        Logger.log(
          'PodDetailsItemController portForward',
          'Internal http server is started and healthy, try to establish port forwarding',
        );

        final result = await KubernetesService(cluster: cluster)
            .portForwarding(name, namespace, port);
        portForwardingController.addSession(
          result['sessionID'],
          name,
          namespace,
          container,
          port,
          result['localPort'],
        );
      } else {
        snackbar(
          'Could not establish port forwarding',
          'The internal http server is unhealthy',
        );
      }
    } catch (err) {
      Logger.log(
        'PodDetailsItemController portForward',
        'Could not establish port forwarding',
        err,
      );
      snackbar(
        'Could not establish port forwarding',
        'An error was returned: $err',
      );
    }
  }

  /// [getMetrics] returns the CPU and Memory usage for each container of the Pod. This function is called in the
  /// during the initalization ([onInit]) of the controller.
  void getMetrics() async {
    final cluster = clusterController.getActiveCluster();
    if (cluster != null &&
        pod != null &&
        pod!.metadata != null &&
        pod!.metadata!.name != null &&
        pod!.metadata!.namespace != null) {
      final url =
          '/apis/metrics.k8s.io/v1beta1/namespaces/${pod!.metadata!.namespace}/pods/${pod!.metadata!.name}';

      try {
        final metricsData =
            await KubernetesService(cluster: cluster).getRequest(url);

        Logger.log(
          'PodDetailsItemController getMetrics',
          'Pod metrics were returned',
          'Request URL: $url\nManifest: $metricsData',
        );
        final containerMetrics =
            ApisMetricsV1beta1PodMetricsItem.fromJson(metricsData).containers;
        if (containerMetrics != null) {
          metrics.value = containerMetrics;
        }
      } on PlatformException catch (err) {
        Logger.log(
          'PodDetailsItemController getMetrics',
          'An error was returned while getting metrics',
          'Code: ${err.code}\nMessage: ${err.message}\nDetails: ${err.details.toString()}',
        );
        metrics.value = [];
      } catch (err) {
        Logger.log(
          'PodDetailsItemController getMetrics',
          'An error was returned while getting metrics',
          err,
        );
        metrics.value = [];
      }
    }

    isLoadingMetricsFinished.value = true;
  }
}

class PodDetailsItemWidget extends StatelessWidget
    implements IDetailsItemWidget {
  const PodDetailsItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final pod = IoK8sApiCoreV1Pod.fromJson(item);

    PodDetailsItemController controller = Get.put(
      PodDetailsItemController(pod: pod),
    );

    if (pod == null || pod.spec == null || pod.status == null) {
      return Container();
    }

    final ready =
        '${pod.status!.containerStatuses.where((containerStatus) => containerStatus.ready).length}/${pod.spec!.containers.length}';
    final restarts = getRestarts(pod);
    final status = getStatusText(pod);
    final ports = getPorts(pod);

    return Column(
      children: [
        DetailsItemWidget(
          title: 'Configuration',
          details: [
            DetailsItemModel(
              name: 'Priority',
              values: pod.spec!.priority ?? '-',
            ),
            DetailsItemModel(
              name: 'Node',
              values: pod.spec!.nodeName ?? '-',
            ),
            DetailsItemModel(
              name: 'Node',
              values: pod.spec!.serviceAccountName ?? '-',
            ),
            DetailsItemModel(
              name: 'Service Account',
              values: pod.spec!.serviceAccountName ?? '-',
            ),
            DetailsItemModel(
              name: 'Restart Policy',
              values: pod.spec!.restartPolicy.toString(),
            ),
            DetailsItemModel(
              name: 'Termination Grace Period Seconds',
              values: pod.spec!.terminationGracePeriodSeconds ?? '-',
            ),
            DetailsItemModel(
              name: 'Ports',
              values: ports != null
                  ? ports
                      .map((port) =>
                          '${port.containerName}: ${port.port.containerPort}${port.port.protocol != null ? '/${port.port.protocol!.value}' : ''}${port.port.name != null ? ' (${port.port.name})' : ''}')
                      .toList()
                  : '-',
              onTap: (index) {
                if (ports != null) {
                  controller.portForward(
                    pod.metadata!.name!,
                    pod.metadata!.namespace!,
                    ports[index].containerName,
                    ports[index].port.containerPort,
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsItemWidget(
          title: 'Status',
          details: [
            DetailsItemModel(
              name: 'Ready',
              values: ready,
            ),
            DetailsItemModel(
              name: 'Restarts',
              values: restarts,
            ),
            DetailsItemModel(
              name: 'Status',
              values: status,
            ),
            DetailsItemModel(
              name: 'QoS',
              values: pod.status!.qosClass.toString(),
            ),
            DetailsItemModel(
              name: 'Pod IP',
              values: pod.status!.podIP ?? '-',
            ),
            DetailsItemModel(
              name: 'Host IP',
              values: pod.status!.hostIP ?? '-',
            ),
          ],
        ),
        const SizedBox(height: Constants.spacingMiddle),
        Obx(() {
          if (controller.isLoadingMetricsFinished.value) {
            return DetailsContainersWidget(
              initContainers: pod.spec!.initContainers,
              containers: pod.spec!.containers,
              initContainerStatuses: pod.status!.initContainerStatuses,
              containerStatuses: pod.status!.containerStatuses,
              containerMetrics: controller.metrics,
            );
          } else {
            return const CircularProgressIndicator(
              color: Constants.colorPrimary,
            );
          }
        }),
        const SizedBox(height: Constants.spacingMiddle),
        DetailsResourcesPreviewWidget(
          title: Resources.map['events']!.title,
          resource: Resources.map['events']!.resource,
          path: Resources.map['events']!.path,
          scope: Resources.map['events']!.scope,
          namespace: pod.metadata?.namespace,
          selector:
              'fieldSelector=involvedObject.name=${pod.metadata?.name ?? ''}',
        ),
        const SizedBox(height: Constants.spacingMiddle),
        AppPrometheusChartsWidget(
          manifest: item,
          defaultCharts: [
            Chart(
              title: 'CPU Usage',
              unit: 'Cores',
              queries: [
                Query(
                  query:
                      'sum(rate(container_cpu_usage_seconds_total{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", container!="", container!="POD"}[2m])) by (container)',
                  label: 'Usage {{ .container }}',
                ),
                Query(
                  query:
                      'sum(kube_pod_container_resource_requests{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", resource="cpu", container!="", container!="POD"}) by (container)',
                  label: 'Requests {{ .container }}',
                ),
                Query(
                  query:
                      'sum(kube_pod_container_resource_limits{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", resource="cpu", container!="", container!="POD"}) by (container)',
                  label: 'Limits {{ .container }}',
                ),
              ],
            ),
            Chart(
              title: 'Memory Usage',
              unit: 'MiB',
              queries: [
                Query(
                  query:
                      '(sum(container_memory_working_set_bytes{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", container!="", container!="POD"}) by (container)) / 1024 / 1024',
                  label: 'Usage {{ .container }}',
                ),
                Query(
                  query:
                      '(sum(kube_pod_container_resource_requests{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", resource="memory", container!="", container!="POD"}) by (container)) / 1024 / 1024',
                  label: 'Requests {{ .container }}',
                ),
                Query(
                  query:
                      '(sum(kube_pod_container_resource_limits{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", resource="memory", container!="", container!="POD"}) by (container)) / 1024 / 1024',
                  label: 'Limits {{ .container }}',
                ),
              ],
            ),
            Chart(
              title: 'Network I/O',
              unit: 'MiB',
              queries: [
                Query(
                  query:
                      'sum(rate(container_network_receive_bytes_total{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}[2m])) by (pod) / 1024 / 1024',
                  label: 'Received',
                ),
                Query(
                  query:
                      '-sum(rate(container_network_transmit_bytes_total{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}"}[2m])) by (pod) / 1024 / 1024',
                  label: 'Transmitted',
                ),
              ],
            ),
            Chart(
              title: 'Restarts',
              unit: '',
              queries: [
                Query(
                  query:
                      'sum(kube_pod_container_status_restarts_total{namespace="{{with .metadata}}{{with .namespace}}{{.}}{{end}}{{end}}", pod="{{with .metadata}}{{with .name}}{{.}}{{end}}{{end}}", container!="", container!="POD"}) by (container)',
                  label: '{{ .container }}',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
