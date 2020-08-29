/*
 * kronos for jQuery
 * Version: 1.0.1
 * Author: shinyongjun
 * Website: http://www.simplizm.com/
 */

;(function ($) {
    'use strict';

    var Kronos = window.Kronos || {};

    Kronos = (function () {
        var fnidx = 0;
        function kronos(element, settings){
            var _ = this;
            var settings = settings === undefined ? {} : settings;
            var defaults = {
                initDate: null,
                format: 'yyyy-mm-dd',
                visible: false,
                disableWeekends : false,
                text: {
                    thisMonth : '.',
                    thisYear : '.',
                    days : ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
                    month : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    btnToday : 'Today',
                    btnTrigger : 'Pick A Date',
                    btnPrevMonth : 'Prev Month',
                    btnNextMonth : 'Next Month',
                    btnPrevYear : 'Prev Year',
                    btnNextYear : 'Next Year'
                },
                periodFrom: false,
                periodTo: false,
                date: {
                    /* ex : ['19910301', '1231'] */
                    disabled: [],
                    holiday: []
                },
                onChange: function () {
                    //console.log(date);
                }
            }
            _.options = $.extend(true, {}, defaults, settings);
            _.initial = {
                fnidx: ++fnidx,
                weekCount: 0,
                actionFlag: false
            };
            _.strings = {}
            _.corevar = {}
            _.events = {
                click: 'click.kronos'+_.initial.fnidx
            }
            _.markups = {
                common: {
                    outer: '<div class="kronos-outer">',
                    inner: '<div class="kronos-inner">'
                },
                year: {
                    outer: '<div class="kronos-year-outer">',
                    inner: '<div class="kronos-year-inner">',

                    head: '<div class="kronos-year-head">',
                    body: '<div class="kronos-year-body">',
                    title: '<button class="kronos-year-title"></button>',

                    prev: '<button type="button" class="kronos-year-prev" title="'+_.options.text.btnYearPrev+'">'+_.options.text.btnYearPrev+'</button>',
                    next: '<button type="button" class="kronos-year-next" title="'+_.options.text.btnYearNext+'">'+_.options.text.btnYearNext+'</button>'
                },
                month: {
                    outer: '<div class="kronos-month-outer">',
                    inner: '<div class="kronos-month-inner">',

                    head: '<div class="kronos-month-head">',
                    body: '<div class="kronos-month-body">',
                    title: '<button class="kronos-month-title"></button>',

                    prev: '<button type="button" class="kronos-month-prev" title="'+_.options.text.btnMonthPrev+'">'+_.options.text.btnMonthPrev+'</button>',
                    next: '<button type="button" class="kronos-month-next" title="'+_.options.text.btnMonthNext+'">'+_.options.text.btnMonthNext+'</button>'
                },
                date: {
                    outer: '<div class="kronos-date-outer">',
                    inner: '<div class="kronos-date-inner">',

                    head: '<div class="kronos-date-head">',
                    body: '<div class="kronos-date-body">',
                    title: '<button class="kronos-date-title"></button>',

                    prev: '<button type="button" class="kronos-date-prev" title="'+_.options.text.btnDatePrev+'">'+_.options.text.btnDatePrev+'</button>',
                    next: '<button type="button" class="kronos-date-next" title="'+_.options.text.btnDateNext+'">'+_.options.text.btnDateNext+'</button>',

                    content: null
                }
            }
            _.element = {
                kronos: $(element).attr('readonly', 'readonly').addClass('kronos-input'),
                kronosF: _.options.periodFrom ? $(_.options.periodFrom) : false,
                kronosT: _.options.periodTo ? $(_.options.periodTo) : false,
                common: {},
                year: {},
                month: {},
                date: {}
            }
            _.init();
        }
        return kronos;
    }());

    // start : util function =================================================================================================================================
    Kronos.prototype.combineZero = function(number) {
        return String(number).length == 1 ? '0' + String(number) : String(number);
    }

    Kronos.prototype.combineCore = function(year, month, date) {
        return String(year)+String(month)+String(date);
    }

    Kronos.prototype.convertFormat = function(core) {
        var _ = this, f, y, m, d;
        y = _.initial.formatY.length === 2 ? String(core.substring(2, 4)) : String(core.substring(0, 4));
        m = String(core.substring(4, 6));
        d = String(core.substring(6, 8));
        f = _.options.format.replace(_.initial.formatY, y).replace(_.initial.formatM, m).replace(_.initial.formatD, d);
        return f;
    }

    Kronos.prototype.isolateCore = function (core, get) {
        switch(get) {
            case 'year+month' :
                return core.substring(0, 6);
                break;
            case 'year' :
                return core.substring(0, 4);
                break;
            case 'month' :
                return core.substring(4, 6);
                break;
            case 'date' :
                return core.substring(6, 8);
                break;
            default :
                return false;
                break;
        }
    }

    Kronos.prototype.autoPrefixer = function (transform) {
        return {
            '-webkit-transform': 'scale(1) translate3d(' + transform + '%, 0, 0)',
            '-moz-transform': 'scale(1) translate3d(' + transform + '%, 0, 0)',
            '-ms-transform': 'scale(1) translate3d(' + transform + '%, 0, 0)',
            'transform': 'scale(1) translate3d(' + transform + '%, 0, 0)'
        }
    }

    Kronos.prototype.slideDatepicker = function (delta, target1, target2, callback) {
        var _ = this;
        _.initial.actionFlag = true;
        setTimeout(function () {
            if (target2) {
                target2.css(_.autoPrefixer(-delta * 100))
            }
            target1.css(_.autoPrefixer(0));
            setTimeout(function () {
                if (target2) {
                    target2.remove();
                }
                callback();
                _.initial.actionFlag = false;
            }, delta ? 300 : 1);
        }, 1);
    }

    Kronos.prototype.visibleMotion = function (type, show, hide) {
        var class1 = type === 'in' ? 'kronos-outer-scale-h' : 'kronos-outer-scale-r';
        var class2 = type === 'in' ? 'kronos-outer-scale-r' : 'kronos-outer-scale-h';
        hide.addClass(class1);
        hide.addClass('kronos-outer-hide');
        show.addClass('kronos-outer-show');
        setTimeout(function () {
            show.removeClass(class2);
            setTimeout(function () {
                hide.removeClass('kronos-outer-hide');
                show.removeClass('kronos-outer-show');
            }, 500);
        }, 200);
    }
    // end : util function =================================================================================================================================



    // start: only one run function =========================================================================================================================
    Kronos.prototype.checkFormat = function () {
        var _ = this;
        _.initial.indexYS = _.options.format.indexOf('y');
        _.initial.indexYE = _.options.format.lastIndexOf('y')+1;
        _.initial.indexMS = _.options.format.indexOf('m');
        _.initial.indexME = _.options.format.lastIndexOf('m')+1;
        _.initial.indexDS = _.options.format.indexOf('d');
        _.initial.indexDE = _.options.format.lastIndexOf('d')+1;
        _.initial.formatY = String(_.options.format.substring(_.initial.indexYS, _.initial.indexYE));
        _.initial.formatM = String(_.options.format.substring(_.initial.indexMS, _.initial.indexME));
        _.initial.formatD = String(_.options.format.substring(_.initial.indexDS, _.initial.indexDE));
    }

    Kronos.prototype.getTodayDate = function () {
        var _ = this;
        _.initial.date = new Date();
        _.initial.todayY = _.initial.date.getFullYear();
        _.initial.todayM = _.initial.date.getMonth();
        _.initial.todayD = _.initial.date.getDate();
        _.initial.dateLeng = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        _.corevar.today = String(_.initial.todayY) + _.combineZero(_.initial.todayM + 1) + _.combineZero(_.initial.todayD);
    }

    Kronos.prototype.setLayout = function () {
        var _ = this;
        _.element.common.outer = _.element.kronos.wrap(_.markups.common.outer).parent('.kronos-outer');
        _.element.common.inner = _.element.common.outer.append(_.markups.common.inner).children('.kronos-inner');
        _.element.year.outer = _.element.common.inner.append(_.markups.year.outer).children('.kronos-year-outer');
        _.element.month.outer = _.element.common.inner.append(_.markups.month.outer).children('.kronos-month-outer');
        _.element.date.outer = _.element.common.inner.append(_.markups.date.outer).children('.kronos-date-outer');
    }

    Kronos.prototype.setKronosValue = function () {
        var _ = this;
        if (_.options.initDate) {
            _.corevar.selectedC = _.options.initDate;
            _.corevar.selectedF = _.convertFormat(_.corevar.selectedC);
            _.element.kronos.attr({'core': _.corevar.selectedC}).val(_.corevar.selectedF);
        }
    }

    Kronos.prototype.setVisible = function () {
        var _ = this;
        if (_.options.visible) {
            _.element.common.outer.addClass('kronos-visible');
            _.openDatepicker();
        }
    }
    // end: only one run function =========================================================================================================================



    Kronos.prototype.openDatepicker = function () {
        // 달력 열기
        var _ = this;
        _.setDateInit(0); // 데이트피커 하위 마크업
        _.element.year.outer.addClass('kronos-outer-scale-h');
        _.element.month.outer.addClass('kronos-outer-scale-h').removeClass('kronos-outer-scale-r');
        _.element.date.outer.removeClass('kronos-outer-scale-r');
        _.element.common.outer.addClass('kronos-open');
        // onEvents
        _.eventsRegister.close(_);
    }

    Kronos.prototype.closeDatepicker = function () {
        // 달력 닫기
        var _ = this;
        _.element.year.outer.empty().addClass('kronos-outer-scale-h');
        _.element.month.outer.empty().addClass('kronos-outer-scale-h').removeClass('kronos-outer-scale-r');
        _.element.date.outer.empty().removeClass('kronos-outer-scale-r');
        _.element.common.outer.removeClass('kronos-open');
        // offEvents
        $(document).off(_.events.click);
    }

    Kronos.prototype.setThisDate = function () {
        var _ = this;
        _.initial.thisY = _.initial.date.getFullYear();
        _.initial.startY = _.initial.thisY - 4 < 0 ? 0 : _.initial.thisY - 4;
        _.initial.endY = _.initial.startY + 8;
        _.initial.thisM = _.initial.date.getMonth();
        _.strings.thisM = _.combineZero(_.initial.thisM + 1);
        _.initial.prevY = _.initial.thisM === 0 ? _.initial.thisY - 1 : _.initial.thisY;
        _.initial.prevM = _.initial.thisM === 0 ? 11 : _.initial.thisM - 1;
        _.initial.nextY = _.initial.thisM === 11 ? _.initial.thisY + 1 : _.initial.thisY;
        _.initial.nextM = _.initial.thisM === 11 ? 0 : _.initial.thisM + 1;
        _.initial.dateLeng[1] = (_.initial.thisY % 4 === 0 && _.initial.thisY % 100 !== 0) || _.initial.thisY % 400 === 0 ? 29 : 28;
        _.initial.thisDateLeng = _.initial.dateLeng[_.initial.thisM];
        _.initial.titleYM = _.initial.thisY + '. ' + _.strings.thisM;
        _.strings.thisYM = _.initial.thisY + _.strings.thisM;
        _.strings.prevYM = _.initial.prevY + _.combineZero(_.initial.prevM + 1);
        _.strings.nextYM = _.initial.nextY + _.combineZero(_.initial.nextM + 1);
        _.initial.date.setDate(1);
        _.initial.thisDay = _.initial.date.getDay();
    }

    Kronos.prototype.setDateInit = function (delta) {
        // 달력 그리기
        var _ = this;
        _.initial.date.setMonth(_.initial.date.getMonth() + delta);
        _.setThisDate(); // 오늘 날짜 데이터 설정
        _.element.date.inner = _.element.date.outer.append(_.markups.date.inner).children('.kronos-date-inner:last-child');
        _.element.date.head = _.element.date.inner.append(_.markups.date.head).children('.kronos-date-head');
        _.element.date.body = _.element.date.inner.append(_.markups.date.body).children('.kronos-date-body');
        _.element.date.prev = _.element.date.head.append(_.markups.date.prev).children('.kronos-date-prev');
        _.element.date.title = _.element.date.head.append(_.markups.date.title).children('.kronos-date-title');
        _.element.date.year = _.element.date.title.append('<span class="kronos-date-year">'+_.initial.thisY+_.options.text.thisYear+'</span>').children('.kronos-date-year');
        _.element.date.month = _.element.date.title.append('<span class="kronos-date-month">'+_.options.text.month[_.initial.thisM]+_.options.text.thisMonth+'</span>').children('.kronos-date-month');
        _.element.date.next = _.element.date.head.append(_.markups.date.next).children('.kronos-date-next');
        _.element.date.inner.css(_.autoPrefixer(delta * 100));
        _.setDayMarkup(); // 요일 마크업 그리기
        _.setDateMarkup(); // 각 날짜 마크업 그리기
        _.getCoreData(); // 코어 데이타 (this, from, to) 가져오기
        _.setDateClasses(); // 각 날짜에 클래스 매핑
        _.slideDatepicker(delta, _.element.date.inner, _.element.date.inner2, function () {
            _.element.date.inner2 = _.element.date.inner;
            _.element.date.inner = null;
        });
        // onEvents
        _.eventsRegister.date(_);
    }

    Kronos.prototype.setMonthInit = function (delta) {
        var _ = this;
        _.element.month.inner = _.element.month.outer.append(_.markups.month.inner).children('.kronos-month-inner:last-child');
        _.element.month.head = _.element.month.inner.append(_.markups.month.head).children('.kronos-month-head');
        _.element.month.body = _.element.month.inner.append(_.markups.month.body).children('.kronos-month-body');
        _.element.month.prev = _.element.month.head.append(_.markups.month.prev).children('.kronos-month-prev');
        _.element.month.next = _.element.month.head.append(_.markups.month.next).children('.kronos-month-next');
        _.element.month.inner.css(_.autoPrefixer(delta * 100));
        _.slideDatepicker(delta, _.element.month.inner, _.element.month.inner2, function () {
            _.element.month.inner2 = _.element.month.inner;
            _.element.month.inner = null;
        });
        _.setMonthMarkup(delta);
        _.element.month.title = _.element.month.head.append(_.markups.month.title).children('.kronos-month-title').text(_.initial.thisY+_.options.text.thisYear);
        // onEvents
        _.eventsRegister.month(_);
    }

    Kronos.prototype.setYearInit = function (delta) {
        var _ = this;
        if (!delta && _.element.year.inner2) {
            _.element.year.inner2.remove();
        }
        _.element.year.inner = _.element.year.outer.append(_.markups.year.inner).children('.kronos-year-inner:last-child');
        _.element.year.head = _.element.year.inner.append(_.markups.year.head).children('.kronos-year-head');
        _.element.year.body = _.element.year.inner.append(_.markups.year.body).children('.kronos-year-body');
        _.element.year.prev = _.element.year.head.append(_.markups.year.prev).children('.kronos-year-prev');
        _.element.year.next = _.element.year.head.append(_.markups.year.next).children('.kronos-year-next');
        _.element.year.inner.css(_.autoPrefixer(delta * 100));
        _.initial.startY = _.initial.thisY - 4 < 0 ? 0 : _.initial.thisY - 4;
        _.initial.endY = _.initial.startY + 8;
        _.slideDatepicker(delta, _.element.year.inner, _.element.year.inner2, function () {
            _.element.year.inner2 = _.element.year.inner;
            _.element.year.inner = null;
        });
        _.setYearMarkup(delta);
        _.element.year.title = _.element.year.head.append(_.markups.year.title).children('.kronos-year-title').text(_.initial.startY+_.options.text.thisYear+' ~ '+_.initial.endY+_.options.text.thisYear);
        // onEvents
        _.eventsRegister.year(_);
    }

    Kronos.prototype.setDayMarkup = function () {
        var _ = this;
        _.markups.date.content = '<table><thead><tr>';
        for (var i = 0; i < 7; i++) {
            _.markups.date.content += '<th>'+_.options.text.days[i]+'</th>';
        }
        _.markups.date.content += '</tr></thead>';
    }

    Kronos.prototype.setDateMarkup = function () {
        var _ = this;
        _.initial.prevMonthFirstDate = _.initial.dateLeng[_.initial.prevM] - _.initial.thisDay;
        _.markups.date.content += '<tbody><tr>';
        for (var i = 1; i <= _.initial.thisDay; i++) {
            // 이전달 마크업
            _.markups.date.content += '<td><button type="button" core="'+_.strings.prevYM+(_.initial.prevMonthFirstDate+i)+'" title="'+_.convertFormat(_.strings.prevYM+(_.initial.prevMonthFirstDate+i))+'">'+(_.initial.prevMonthFirstDate+i)+'</button></td>';
            _.initial.weekCount++;
        }
        for (var i = 1; i <= _.initial.thisDateLeng; i++) {
            // 이번달 마크업
            if (_.initial.weekCount === 0) {
                _.markups.date.content += '<tr>';
            }
            _.markups.date.content += '<td><button type="button" core="'+_.strings.thisYM+_.combineZero(i)+'" title="'+_.convertFormat(_.strings.thisYM+_.combineZero(i))+'">'+i+'</button></td>';
            _.initial.weekCount++;
            if (_.initial.weekCount === 7) {
                _.markups.date.content += '</tr>';
                _.initial.weekCount = 0;
            }
        }
        for (var i = 1; _.initial.weekCount != 0; i++) {
            // 다음달 마크업
            if (_.initial.weekCount === 7) {
                _.markups.date.content += '</tr>';
                _.initial.weekCount = 0;
            } else {
                _.markups.date.content += '<td><button type="button" core="'+_.strings.nextYM+_.combineZero(i)+'" title="'+_.convertFormat(_.strings.nextYM+_.combineZero(i))+'">'+i+'</button></td>';
                _.initial.weekCount++;
            }
        }
        _.markups.date.content += '</tbody></table>';
        _.element.date.body.html(_.markups.date.content);
        _.element.common.inner.css({'height': _.element.date.inner.outerHeight()});
        _.element.date.date = _.element.date.body.find('td');
    }

    Kronos.prototype.getCoreData = function () {
        var _ = this;
        if (_.element.kronos.attr('core')) {
            _.corevar.selectedC = _.element.kronos.attr('core');
            _.corevar.selectedF = _.convertFormat(_.corevar.selectedC);
        }

        if (_.element.kronosF && _.element.kronosF.attr('core')) {
            _.corevar.fromC = _.element.kronosF.attr('core');
            _.corevar.fromF = _.convertFormat(_.corevar.fromC);
        }

        if (_.element.kronosT && _.element.kronosT.attr('core')) {
            _.corevar.toC = _.element.kronosT.attr('core');
            _.corevar.toF = _.convertFormat(_.corevar.toC);
        }
    }

    Kronos.prototype.setDateClasses = function () {
        var _ = this;
        _.element.date.date.removeClass();
        _.element.date.date.each(function () {
            this.index = $(this).index();
            this.core = $(this).find('button').attr('core');
            this.mmdd = String(this.core).substring(4, 8);

            this.Class = this.index === 0
                ? 'sunday' : this.index === 6
                ? 'satday' : ''; // weekend
            this.Class += this.core === _.corevar.selectedC
                || this.core === _.corevar.fromC
                || this.core === _.corevar.toC
                ? ' selected' : ''; // selected
            this.Class += _.corevar.selectedC && _.corevar.fromC && this.core > _.corevar.fromC && this.core < _.corevar.selectedC
                || _.corevar.selectedC && _.corevar.toC && this.core < _.corevar.toC && this.core > _.corevar.selectedC
                ? ' period' : ''; // period
            this.Class += this.core === _.corevar.today ? ' today' : '';
            this.Class += _.isolateCore(this.core, 'year+month') === _.strings.prevYM
                || _.options.disableWeekends && (this.index === 0 || this.index === 6)
                || _.isolateCore(this.core, 'year+month') === _.strings.nextYM
                || _.corevar.fromC && this.core < _.corevar.fromC
                || _.corevar.toC && this.core > _.corevar.toC
                || _.options.date.disabled.indexOf(this.core) !== -1
                || _.options.date.disabled.indexOf(this.mmdd) !== -1
                ? ' disabled' : '';
            this.Class += _.options.date.holiday.indexOf(this.core) !== -1
                || _.options.date.holiday.indexOf(this.mmdd) !== -1
                ? ' holiday' : '';
            $(this).addClass(this.Class);
        });
    }

    Kronos.prototype.setMonthMarkup = function (delta) {
        var _ = this;
        _.initial.thisY = parseInt(_.initial.thisY) + parseInt(delta);
        for (var i = 0; i < 12; i++) {
            _.element.month.body.append('<button core="'+_.initial.thisY+_.combineZero(i+1)+'" class="'+(_.initial.thisY === _.initial.date.getFullYear() && i === _.initial.thisM ? 'selected' : '')+'">'+(i+1)+'</button>');
        }
        _.element.month.month = _.element.month.body.find('button');
    }

    Kronos.prototype.setYearMarkup = function (delta) {
        var _ = this;
        _.initial.startY = _.initial.startY + (9 * delta) < 0 ? 0 : _.initial.startY + (9 * delta);
        _.initial.thisY = _.initial.thisY + (9 * delta);
        _.initial.endY = _.initial.startY + 8;
        for (var i = _.initial.startY; i <= _.initial.endY; i++) {
            _.element.year.body.append('<button core="'+i+'" class="'+(i === _.initial.date.getFullYear() ? 'selected' : '')+'">'+i+'</button>');
        }
        _.element.year.year = _.element.year.body.find('button');
    }

    Kronos.prototype.eventsRegister = (function () {
        return {
            open: function (_) {
                if (!_.options.visible) {
                    _.element.kronos.on(_.events.click, function (e) {
                        _.openDatepicker();
                    });
                }
            },
            close: function (_) {
                $(document).on(_.events.click, function (e) {
                    if (!$(e.target).closest(_.element.common.outer).length && !_.options.visible) {
                        _.closeDatepicker();
                    }
                });
            },
            date: function (_) {
                _.element.date.title.on(_.events.click, function () {
                    _.setMonthInit(0);
                    _.visibleMotion('out', _.element.month.outer, _.element.date.outer);
                });
                _.element.date.date.on(_.events.click, function () {
                    if (!$(this).hasClass('disabled')) {
                        _.element.kronos.val(_.convertFormat(this.core)).attr({'core': this.core});
                        _.options.onChange(this.core);

                        if (_.options.visible) {
                            _.getCoreData();
                            _.setDateClasses();

                            if (_.element.kronosF) {
                                _.element.kronosF.kronos('getCoreData');
                                _.element.kronosF.kronos('setDateClasses');
                            }

                            if (_.element.kronosT) {
                                _.element.kronosT.kronos('getCoreData');
                                _.element.kronosT.kronos('setDateClasses');
                            }
                        } else {
                            _.closeDatepicker();
                        }
                    }
                });
                _.element.date.next.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setDateInit(1);
                    }
                });
                _.element.date.prev.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setDateInit(-1);
                    }
                });
            },
            month: function (_) {
                _.element.month.title.on(_.events.click, function () {
                    _.setYearInit(0);
                    _.visibleMotion('out', _.element.year.outer, _.element.month.outer);
                });
                _.element.month.month.on(_.events.click, function () {
                    _.initial.date.setFullYear(_.initial.thisY);
                    _.initial.date.setMonth(parseInt($(this).text()) - 1);
                    _.setDateInit(0);

                    _.visibleMotion('in', _.element.date.outer, _.element.month.outer);
                });
                _.element.month.next.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setMonthInit(1);
                    }
                });
                _.element.month.prev.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setMonthInit(-1);
                    }
                });
            },
            year: function (_) {
                _.element.year.year.on(_.events.click, function () {
                    _.initial.date.setFullYear($(this).attr('core'));
                    _.initial.thisY = $(this).attr('core');
                    _.setMonthInit(0);

                    _.visibleMotion('in', _.element.month.outer, _.element.year.outer);
                });
                _.element.year.next.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setYearInit(1);
                    }
                });
                _.element.year.prev.on(_.events.click, function () {
                    if (!_.initial.actionFlag) {
                        _.setYearInit(-1);
                    }
                });
            }
        }
    })();

    Kronos.prototype.init = function () {
        var _ = this;
        _.checkFormat();
        _.getTodayDate();
        _.setLayout();
        _.setKronosValue();
        _.setVisible();
        _.eventsRegister.open(_);
    }

    Kronos.prototype.resetPeriod = function () {
        var _ = this;
        _.element.kronos.val(null).attr('core', null);
        _.corevar.selectedC = null;
        _.corevar.selectedF = null;
        _.corevar.fromC = null;
        _.corevar.fromF = null;
        _.corevar.toC = null;
        _.corevar.toF = null;
        _.setDateClasses();
    }

    $.fn.kronos = function () {
        var _ = this,
            o = arguments[0],
            s = Array.prototype.slice.call(arguments, 1),
            l = _.length,
            r;
        for(var i = 0; i < l; i++) {
            if (typeof o == 'object' || typeof o == 'undefined') {
                _[i].Kronos = new Kronos(_[i], o);
            } else {
                r = _[i].Kronos[o].apply(_[i].Kronos, s);
                if (typeof r != 'undefined') {
                    return r;
                }
            }
        }
        return;
    }
}(jQuery));
