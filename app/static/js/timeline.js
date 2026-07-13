// Timeline page: submit posts via the fetch API and render them newest-first.
// Form-submit-with-fetch pattern based on:
// https://openjavascript.info/2022/04/26/post-form-data-using-javascripts-fetch-api/

const API_URL = "/api/timeline_post";

// Build a Gravatar image URL from an email address. Gravatar accepts a SHA-256
// hex hash of the trimmed, lower-cased email, which we can compute with the
// browser's built-in crypto (no MD5 library needed).
// https://docs.gravatar.com/api/avatars/images/
async function gravatarUrl(email, size = 64) {
  const normalized = email.trim().toLowerCase();
  const bytes = new TextEncoder().encode(normalized);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  const hash = Array.from(new Uint8Array(digest))
    .map(b => b.toString(16).padStart(2, "0"))
    .join("");
  return `https://gravatar.com/avatar/${hash}?d=identicon&s=${size}`;
}

function formatDate(value) {
  const date = new Date(value);
  return isNaN(date) ? value : date.toLocaleString();
}

async function renderPost(post) {
  const li = document.createElement("li");
  li.className = "timeline-post";

  const avatar = document.createElement("img");
  avatar.className = "timeline-avatar";
  avatar.src = await gravatarUrl(post.email);
  avatar.alt = `${post.name}'s avatar`;

  const body = document.createElement("div");
  body.className = "timeline-body";

  const header = document.createElement("div");
  header.className = "timeline-post-header";
  const name = document.createElement("strong");
  name.textContent = post.name;
  const date = document.createElement("small");
  date.textContent = formatDate(post.created_at);
  header.append(name, date);

  const email = document.createElement("span");
  email.className = "timeline-post-email";
  email.textContent = post.email;

  const content = document.createElement("p");
  content.textContent = post.content;

  body.append(header, email, content);
  li.append(avatar, body);
  return li;
}

async function loadPosts() {
  const list = document.getElementById("timeline-list");
  const res = await fetch(API_URL);
  const data = await res.json();

  list.innerHTML = "";
  if (!data.timeline_posts.length) {
    const empty = document.createElement("li");
    empty.className = "timeline-empty";
    empty.textContent = "No posts yet. Be the first to add one!";
    list.append(empty);
    return;
  }

  // The API already returns posts in descending order (newest first).
  const items = await Promise.all(data.timeline_posts.map(renderPost));
  items.forEach(item => list.append(item));
}

async function handleSubmit(event) {
  event.preventDefault();
  const form = event.target;
  const error = document.getElementById("timeline-error");
  error.hidden = true;

  try {
    const res = await fetch(API_URL, {
      method: "POST",
      body: new FormData(form),
    });
    if (!res.ok) {
      throw new Error(`Server responded with ${res.status}`);
    }
    form.reset();
    await loadPosts();
  } catch (err) {
    error.textContent = `Could not post: ${err.message}`;
    error.hidden = false;
  }
}

export function initTimeline() {
  document.getElementById("timeline-form").addEventListener("submit", handleSubmit);
  loadPosts();
}
