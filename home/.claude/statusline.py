#!/usr/bin/env python3
import json, sys, subprocess
from datetime import datetime, timezone, timedelta

R   = '\033[0m'
DIM = '\033[2m'
GRAY   = '\033[38;2;107;112;137m'
GREEN  = '\033[38;2;180;190;130m'
YELLOW = '\033[38;2;226;164;120m'
RED    = '\033[38;2;226;120;120m'
BLUE   = '\033[38;2;132;160;198m'
CYAN   = '\033[38;2;137;184;194m'

AUTOCOMPACT_PCT = 75
JST = timezone(timedelta(hours=9))

def bar(pct, width=20):
    pct = min(max(pct, 0), 100)
    full = int(pct * width / 100 + 0.5)
    return '[' + '=' * full + '-' * (width - full) + ']'

def bar_color(pct):
    if pct >= AUTOCOMPACT_PCT: return RED
    if pct >= 50:              return YELLOW
    return BLUE

def fmt_time(dt, include_date):
    hour = str(dt.hour % 12 or 12)
    ampm = 'AM' if dt.hour < 12 else 'PM'
    if include_date:
        return f'{dt.month:02d}/{dt.day:02d} {hour}{ampm}'
    return f'{hour}{ampm}'

def reset_str(resets_at, include_date=False):
    if not resets_at:
        return ''
    dt = datetime.fromtimestamp(resets_at, tz=JST)
    return f'  {DIM}Resets {fmt_time(dt, include_date)} (JST){R}'

def fmt_part(label, pct, resets_at=None, include_date=False, is_ctx=False):
    color = bar_color(pct)
    b = bar(pct)
    r = reset_str(resets_at, include_date) if resets_at else ''
    compact_warn = ''
    if is_ctx and 50 <= pct < AUTOCOMPACT_PCT:
        remaining = AUTOCOMPACT_PCT - pct
        compact_warn = f'  {DIM}Until auto-compact: {remaining}%{R}'
    return f'{DIM}{label:<3} {R}{color}{b}{DIM} {pct:3d}%{R}{compact_warn}{r}'

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

model     = (data.get('model') or {}).get('display_name', 'Claude')
ctx       = (data.get('context_window') or {}).get('used_percentage') or 0
cwd       = data.get('cwd', '')
lines_add = (data.get('cost') or {}).get('total_lines_added') or 0
lines_del = (data.get('cost') or {}).get('total_lines_removed') or 0
five      = (data.get('rate_limits') or {}).get('five_hour') or {}
week      = (data.get('rate_limits') or {}).get('seven_day') or {}
five_pct  = five.get('used_percentage')
five_rst  = five.get('resets_at')
week_pct  = week.get('used_percentage')
week_rst  = week.get('resets_at')

# git branch
git_branch = ''
if cwd:
    try:
        git_branch = subprocess.check_output(
            ['git', '-C', cwd, '--no-optional-locks', 'rev-parse', '--abbrev-ref', 'HEAD'],
            stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        pass

home = __import__('os').environ.get('HOME', '')
cwd_display = cwd.replace(home, '~', 1) if cwd.startswith(home) else cwd

SEP = f'{GRAY} │ {R}'
now = datetime.now().strftime('%H:%M')
line1 = f' {DIM}{model}{R}{SEP}{DIM}{now}{R}'
if cwd_display:
    line1 += f'{SEP}{BLUE}{cwd_display}{R}'
if git_branch:
    if lines_add > 0 or lines_del > 0:
        line1 += f'{SEP}{CYAN}{git_branch}{R} {GREEN}(+{lines_add}/-{lines_del}){R}'
    else:
        line1 += f'{SEP}{CYAN}{git_branch}{R}'

out = line1 + '\n'
out += ' ' + fmt_part('ctx', ctx, is_ctx=True) + '\n'
if five_pct is not None:
    out += ' ' + fmt_part('5h', five_pct, five_rst, include_date=False) + '\n'
else:
    out += f' {DIM}5h  [--------------------]  --%{R}\n'
if week_pct is not None:
    out += ' ' + fmt_part('7d', week_pct, week_rst, include_date=True) + '\n'
else:
    out += f' {DIM}7d  [--------------------]  --%{R}\n'

print(out, end='')
