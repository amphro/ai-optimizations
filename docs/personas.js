function switchPersona(id) {
  document.querySelectorAll('.persona-panel').forEach(function(p) {
    p.classList.remove('active');
  });
  document.querySelectorAll('.persona-tab').forEach(function(t) {
    t.classList.remove('active');
    t.setAttribute('aria-selected', 'false');
  });

  var panel = document.getElementById('persona-' + id);
  var tab = document.getElementById('tab-' + id);

  if (panel) panel.classList.add('active');
  if (tab) {
    tab.classList.add('active');
    tab.setAttribute('aria-selected', 'true');
  }
}

document.addEventListener('DOMContentLoaded', function() {
  switchPersona('pro');
});
