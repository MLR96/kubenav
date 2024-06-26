//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: require_trailing_commas
// ignore_for_file: unused_element
// ignore_for_file: unnecessary_this
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:kubenav/models/kubernetes/helpers.dart';
import 'package:kubenav/models/plugins/flux/io_fluxcd_toolkit_image_v1beta1_image_repository_spec_access_from_namespace_selectors_inner.dart';

class IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom {
  /// Returns a new [IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom] instance.
  IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom({
    this.namespaceSelectors = const [],
  });

  /// NamespaceSelectors is the list of namespace selectors to which this ACL applies. Items in this list are evaluated using a logical OR operation.
  List<IoFluxcdToolkitImageV1beta1ImageRepositorySpecAccessFromNamespaceSelectorsInner>
      namespaceSelectors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom &&
          deepEquality.equals(other.namespaceSelectors, namespaceSelectors);

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (namespaceSelectors.hashCode);

  @override
  String toString() =>
      'IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom[namespaceSelectors=$namespaceSelectors]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'namespaceSelectors'] = this.namespaceSelectors;
    return json;
  }

  /// Returns a new [IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom? fromJson(
      dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key),
              'Required key "IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom[$key]" is missing from JSON.');
          assert(json[key] != null,
              'Required key "IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom(
        namespaceSelectors:
            IoFluxcdToolkitImageV1beta1ImageRepositorySpecAccessFromNamespaceSelectorsInner
                .listFromJson(json[r'namespaceSelectors']),
      );
    }
    return null;
  }

  static List<IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value =
            IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom>
      mapFromJson(dynamic json) {
    final map = <String, IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom.fromJson(
            entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom-objects as value to a dart map
  static Map<String, List<IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom>>
      mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map =
        <String, List<IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] =
            IoFluxcdToolkitSourceV1beta1BucketSpecAccessFrom.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'namespaceSelectors',
  };
}
