These files are for building docker files and make containers easily.
run_hadoop is script file for making containers.

---

##### run_hadoop 실행 방법

./run_hadoop [네트워크 이름] [master 컨테이너 만듦 여부] [만들 slave 컨테이너의 첫 범위] [만들 slave 컨테이너의 마지막 범위] [총 slaves 컨테이너 개수]

예) 
```./run_hadoop my-net 1 1 3 10```

설명)
두번째 파라미터가 1 이기 때문에 master 컨테이너를 만들고,
세번째, 네번째 파라미터가 1,3 이기 때문에 slaves 3개, 즉 slave1, slave2, slave3 컨테이너들을 만들고,
첫번째 파라미터 값에 따라 my-net이라는 네트워크에 연결한다.
master 컨테이너를 만들 때(두번째 파라미터가 1일 때) 마지막 파라미터 값에 따라,
workers file에 slaves 이름을 1부터 10까지 순서대로 10개(slave1, slave2, .. slave10) 추가한다.

---

reference
https://hub.docker.com/r/sequenceiq/spark/
https://github.com/sequenceiq/docker-spark

