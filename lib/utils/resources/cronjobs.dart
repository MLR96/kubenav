import 'package:kubenav/models/kubernetes/io_k8s_api_batch_v1_cron_job.dart';
import 'package:kubenav/utils/resources/general.dart';

List<String> buildInfoText(IoK8sApiBatchV1CronJob? cronJob) {
  final age = getAge(cronJob?.metadata?.creationTimestamp);
  final schedule = cronJob?.spec?.schedule;
  final suspend =
      cronJob?.spec?.suspend == null || cronJob?.spec?.suspend == false
          ? 'False'
          : 'True';
  final active = cronJob?.status?.active.length ?? 0;
  final lastSchedule = getAge(cronJob?.status?.lastScheduleTime);

  return [
    'Namespace: ${cronJob?.metadata?.namespace ?? '-'}',
    'Schedule: $schedule',
    'Suspend: $suspend',
    'Active: $active',
    'Last Schedule: $lastSchedule',
    'Age: $age',
  ];
}
