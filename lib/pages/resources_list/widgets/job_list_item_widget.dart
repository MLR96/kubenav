import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/io_k8s_api_batch_v1_job.dart';
import 'package:kubenav/models/resource_model.dart';
import 'package:kubenav/pages/resources_list/widgets/list_item_widget.dart';
import 'package:kubenav/utils/resources/jobs.dart';

class JobListItemWidget extends StatelessWidget implements IListItemWidget {
  const JobListItemWidget({
    Key? key,
    required this.title,
    required this.resource,
    required this.path,
    required this.scope,
    required this.item,
  }) : super(key: key);

  @override
  final String? title;
  @override
  final String? resource;
  @override
  final String? path;
  @override
  final ResourceScope? scope;
  @override
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final job = IoK8sApiBatchV1Job.fromJson(item);
    final completions = job?.spec?.completions ?? 0;
    final succeeded = job?.status?.succeeded ?? 0;
    final info = buildInfoText(job);

    return ListItemWidget(
      title: title,
      resource: resource,
      path: path,
      scope: scope,
      name: job?.metadata?.name ?? '',
      namespace: job?.metadata?.namespace,
      info: info,
      status: completions != 0 && completions != succeeded
          ? Status.danger
          : Status.success,
    );
  }
}
