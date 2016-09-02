
angular.module('app.controllers.forms', []).controller('FormsController', function ($scope, $rootScope, $location, $log, API) {
  
  'use strict';

  $log.debug('FormsController()');
  
  $scope.defaultForm = {};

  $scope.dataLoaded = true;
  
  $scope.submit = function () {
    var promise = API.get(null, $scope.defaultForm);
    promise.success(function (data) {
      $log.debug('FormsController(): success: data:', data);
    }).error(function (data) {
      $log.error('FormsController(): error: data:', data);
    });
  };

});
