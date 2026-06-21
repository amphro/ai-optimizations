(function () {
  var descriptions = {
    '7yo':     'Big ideas in small words. No confusing stuff.',
    'elderly': 'No hurry, no jargon. One step at a time.',
    'pro':     'You already use AI. Here\'s what\'s actually happening.',
    'biz':     'What AI means for your business. No fluff.',
    'eng':     'Technical depth. No hand-holding.',
    'ux':      'Systems thinking, user impact, design decisions.'
  };

  window.switchPersona = function (id) {
    document.querySelectorAll('.persona-panel').forEach(function (p) {
      p.classList.remove('active');
    });
    document.querySelectorAll('.persona-panel[data-persona="' + id + '"]').forEach(function (p) {
      p.classList.add('active');
    });

    document.querySelectorAll('.persona-tab').forEach(function (t) {
      var on = t.dataset.persona === id;
      t.classList.toggle('active', on);
      t.setAttribute('aria-selected', on ? 'true' : 'false');
      t.setAttribute('tabindex', on ? '0' : '-1');
    });

    var sel = document.getElementById('persona-select');
    if (sel) sel.value = id;

    var desc = document.getElementById('persona-description');
    if (desc) desc.textContent = descriptions[id] || '';
    var sdesc = document.getElementById('sticky-description');
    if (sdesc) sdesc.textContent = descriptions[id] || '';
  };

  document.addEventListener('DOMContentLoaded', function () {
    var picker = document.getElementById('persona-picker');
    var sticky = document.getElementById('learn-sticky');
    if (picker && sticky && window.IntersectionObserver) {
      new IntersectionObserver(function (entries) {
        var gone = !entries[0].isIntersecting;
        sticky.classList.toggle('visible', gone);
        sticky.setAttribute('aria-hidden', gone ? 'false' : 'true');
      }, { rootMargin: '-56px 0px 0px 0px', threshold: 0 }).observe(picker);
    }

    document.querySelectorAll('[role="tablist"]').forEach(function (list) {
      list.addEventListener('keydown', function (e) {
        var tabs = Array.from(list.querySelectorAll('[role="tab"]'));
        var i = tabs.indexOf(document.activeElement);
        if (i === -1) return;
        var next = -1;
        if (e.key === 'ArrowRight' || e.key === 'ArrowDown') next = (i + 1) % tabs.length;
        else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') next = (i - 1 + tabs.length) % tabs.length;
        else if (e.key === 'Home') next = 0;
        else if (e.key === 'End') next = tabs.length - 1;
        if (next !== -1) {
          e.preventDefault();
          switchPersona(tabs[next].dataset.persona);
          tabs[next].focus();
        }
      });
    });

    switchPersona('7yo');
  });
}());
