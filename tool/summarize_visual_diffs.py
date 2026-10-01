"""Print diff stats from manifest.json, worst first."""
import json

m = json.load(open('requirements/req-pendulum-lab/visual-qa/manifest.json',
                    encoding='utf-8'))
rows = [
    (s['state'], s['diff']['mean_abs_diff'], s['diff']['pct_pixels_changed'],
     s['diff']['pct_pixels_delta_gt32'])
    for s in m['states'] if s.get('diff') and 'png' in s['diff']
]
rows.sort(key=lambda r: -r[3])
print('{:<24}{:>9}{:>10}{:>10}'.format('state', 'mean_abs', 'changed%', 'd>32%'))
for r in rows:
    print('{:<24}{:>9}{:>10}{:>10}'.format(*r))
