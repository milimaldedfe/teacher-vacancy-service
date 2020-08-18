window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.querySelectorAll('#more-links li a')).map(li => li.setAttribute('tabindex', '-1'))
  document.getElementById('see-more').addEventListener('click', () => {
    document.getElementById('more-links').classList.toggle('govuk-visually-hidden')
    if (document.getElementById('more-links').classList.contains('govuk-visually-hidden')) {
      document.getElementById('see-more').innerHTML = '<i class="fa fa-caret-down govuk-!-margin-right-1"></i>See more cities';
      Array.from(document.querySelectorAll('#more-links li a')).map(li => li.setAttribute('tabindex', '-1'))
    } else {
      document.getElementById('see-more').innerHTML = '<i class="fa fa-caret-up govuk-!-margin-right-1"></i>See less cities';
      Array.from(document.querySelectorAll('#more-links li a')).map(li => li.setAttribute('tabindex', '0'))
    }
  })
});