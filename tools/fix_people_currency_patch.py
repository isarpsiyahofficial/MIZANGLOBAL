from pathlib import Path

p = Path('lib/screens/people_screen.dart')
s = p.read_text(encoding='utf-8')

s = s.replace(
"""    final total = person.banks.fold<double>(
      0.0,
      (sum, bank) => sum + bank.totalDebt,
    );
""",
'',
1,
)

start = s.index('_RecordDetailData _detailData(')
sub = s.index('case RecordType.subscription:', start)
rent = s.index('case RecordType.rent:', sub)
sub_region = s[sub:rent]
if 'currencyCode:' not in sub_region[:sub_region.find('remainingAmount:')]:
    sub_region = sub_region.replace(
        "amountLabel: 'Bu dönem kalan',",
        "amountLabel: 'Bu dönem kalan',\n        currencyCode: item.currencyCode,",
        1,
    )
s = s[:sub] + sub_region + s[rent:]

rent = s.index('case RecordType.rent:', s.index('_RecordDetailData _detailData('))
rent_region = s[rent:]
if 'currencyCode:' not in rent_region[:rent_region.find('remainingAmount:')]:
    rent_region = rent_region.replace(
        "amountLabel: 'Kalan tutar',",
        "amountLabel: 'Kalan tutar',\n        currencyCode: rent.currencyCode,",
        1,
    )
s = s[:rent] + rent_region

p.write_text(s, encoding='utf-8')
