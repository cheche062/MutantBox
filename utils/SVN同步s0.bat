f:
cd F:\h5_release\qa
svn update
svn merge http://10.8.188.3:8081/svn/BattleSpace/mutantbox/h5/release/dev

cd F:\h5_release\s0
svn update
svn merge http://10.8.188.3:8081/svn/BattleSpace/mutantbox/h5/release/dev

cd F:\h5_release\sw0
svn update
svn merge http://10.8.188.3:8081/svn/BattleSpace/mutantbox/h5/release/dev

rem cd F:\h5_release
rem cd update 
rem svn commit -m "New Version"
pause