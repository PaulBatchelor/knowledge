if [ ! -f a.db ]
then
    echo "Generating a.db"
    dagzet ../problems.dz | sqlite3 a.db
fi

PSET_STUDY_TEMPLATE=pset_study_template
PSETS=psets

echo "Generating $PSET_STUDY_TEMPLATE"
sqlite3 a.db < select_psets.sql | awk -f pset_to_tex.awk > $PSET_STUDY_TEMPLATE.tex

pdftex $PSET_STUDY_TEMPLATE > /dev/null

echo "Generating $PSETS"
sqlite3 a.db < generate_psets.sql | python3 psets.py > $PSETS.tex
pdftex $PSETS > /dev/null
