---
layout: page
permalink: /home
---

<div class="container">
  <div class="row">
    <div class="col-sm-8">
      <h3>
        Recent Pages
      </h3>
    </div>
    <div class="col-sm-4" style="background-color: gray-light;">
      <div class="row">
        <h3>
          About Me
        </h3>
      </div>
      <div class="row">
        <h3>
          Categories
        </h3>
        {% for category in site.categories %}
          <ul style="list-style-type: disc">
            {% capture category_name %}{{ category | first }}{% endcapture %}
            <li>
              <a href="{{ site.basurl }}category/{{ category_name }}">
                {{ category_name }}
              </a>
            </li>
          </ul>
        {% endfor %}
      </div>
    </div>
  </div>
</div>
