(function () {
  'use strict';

  angular
       .module('myvcFrontApp')
       .directive('fixedColumnTable', fixedColumnTable);

  fixedColumnTable.$inject = ['$timeout'];
  function fixedColumnTable($timeout) {
      return {
          restrict: 'A',
          scope: {
              fixedColumns: "@"
          },
          link: function (scope, element) {
              var container = element[0];

              function activate() {
                  //applyClasses('thead tr', 'cross', 'th');
                  //applyClasses('tbody tr', 'fixed-cell', 'td');

                  //var leftHeaders = [].concat.apply([], $('table td.fixed-cell'));
                  //var topHeaders = [].concat.apply([], container.querySelectorAll('.inmovible thead th'));
                  //var crossHeaders = [].concat.apply([], container.querySelectorAll('.inmovible thead th.cross'));

                  container.addEventListener('scroll', function () {

                      var x = container.scrollLeft;
                      var y = container.scrollTop;

                      //Update the left header positions when the container is scrolled
                      /*leftHeaders.forEach(function (leftHeader) {
                        leftHeader.style.transform = translate(x, 0);
                      });*/
                      //Update the left header positions when the container is scrolled

                      $('.inmovible td.fixed-cell').css( {'transform': 'translate(' + x +'px, 0)'});

                      /*
                      //Update the top header positions when the container is scrolled
                      topHeaders.forEach(function (topHeader) {
                        topHeader.style.transform = translate(0, y);
                      });

                      //Update headers that are part of the header and the left column
                      crossHeaders.forEach(function (crossHeader) {
                          crossHeader.style.transform = translate(x, y);
                      });*/

                  });

                  function translate(x, y) {
                      return 'translate(' + x + 'px, ' + y + 'px)';
                  }

                  function applyClasses(selector, newClass, cell) {
                      var arrayItems = [].concat.apply([], container.querySelectorAll(selector));
                      var currentElement;
                      var colspan;

                      arrayItems.forEach(function (row, i) {
                          var numFixedColumns = scope.fixedColumns;
                          for (var j = 0; j < numFixedColumns; j++) {
                              currentElement = angular.element(row).find(cell)[j];
                              currentElement.classList.add(newClass);

                              if (currentElement.hasAttribute('colspan')) {
                                  colspan = currentElement.getAttribute('colspan');
                                  numFixedColumns -= (parseInt(colspan) - 1);
                              }
                          }
                      });
                  }
              }

              $timeout(function () {
                  activate();
              }, 0);

              scope.$on('refreshFixedColumns', function() {
                  $timeout(function () {
                      activate();
                      container.scrollLeft = 0;
                  }, 0);
              });
          }
      };
  }
})();
