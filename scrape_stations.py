import json
import time
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup


BASE_URL = "https://onlineradio.ph"
STATIONS_URL = f"{BASE_URL}/stations"
OUTPUT_FILE = "stations.json"
REQUEST_DELAY = 1
MAX_PAGES = 100
MAX_STATIONS = 100

session = requests.Session()
session.headers.update(
    {
        "User-Agent": (
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/126.0 Safari/537.36"
        ),
        "Accept-Language": "en-US,en;q=0.9",
    }
)


def get_soup(url, params=None):
    response = session.get(url, params=params, timeout=30)
    response.raise_for_status()
    return BeautifulSoup(response.text, "html.parser")


def is_station_url(url):
    parsed = urlparse(url)
    return (
        parsed.netloc == urlparse(BASE_URL).netloc
        and parsed.path.count("/") == 1
        and parsed.path.endswith(".html")
    )


def station_links_on_page(page):
    soup = get_soup(STATIONS_URL, params={"page": page})
    links = set()

    for anchor in soup.select('a[href$=".html"]'):
        absolute_url = urljoin(BASE_URL, anchor.get("href"))
        if is_station_url(absolute_url):
            links.add(absolute_url)

    return links


def get_station_links():
    all_links = set()

    for page in range(1, MAX_PAGES + 1):
        page_links = station_links_on_page(page)
        new_links = page_links - all_links

        print(
            f"Directory page {page}: "
            f"{len(page_links)} links, {len(new_links)} new"
        )

        # The footer repeats popular stations. When a page contributes no new
        # station URL, the end of the directory has been reached.
        if not new_links:
            break

        all_links.update(new_links)

        if len(all_links) >= MAX_STATIONS:
            break

        time.sleep(REQUEST_DELAY)

    return sorted(all_links)[:MAX_STATIONS]


def parse_station(url):
    soup = get_soup(url)
    heading = soup.select_one("h1")
    title = heading.get_text(" ", strip=True) if heading else ""

    # The main Play button contains the station's direct audio stream.
    # Prefer the element whose title matches the page heading because station
    # pages also contain Play buttons for similar stations.
    player = None
    for candidate in soup.select("[data-stream-url]"):
        if candidate.get("data-title", "").strip() == title:
            player = candidate
            break

    if player is None:
        player = soup.select_one("[data-stream-url]")

    return {
        "url": url,
        "title": title,
        "stream_url": player.get("data-stream-url", "").strip() if player else "",
    }


def save_stations(stations):
    with open(OUTPUT_FILE, "w", encoding="utf-8") as file:
        json.dump(stations, file, indent=2, ensure_ascii=False)


def main():
    stations = []
    links = get_station_links()

    print(f"\nFound {len(links)} unique station links\n")

    for index, url in enumerate(links, start=1):
        try:
            station = parse_station(url)
            stations.append(station)

            print(f"[{index}/{len(links)}]")
            print(json.dumps(station, indent=2, ensure_ascii=False))
            print("-" * 80)

            # Update the JSON file after every successful station so the
            # results can be viewed while the scraper is still running.
            save_stations(stations)
        except requests.RequestException as error:
            print(f"Request failed for {url}: {error}")
        except Exception as error:
            print(f"Could not parse {url}: {error}")

        time.sleep(REQUEST_DELAY)

    save_stations(stations)

    print(f"\nDone! Saved {len(stations)} stations to {OUTPUT_FILE}.")


if __name__ == "__main__":
    main()
