from hello import Person  


class Worker(Person):
    def __init__(self, name, score, job):
        super(Worker, self).__init__(name, score)
        self.job = job

    def showJob(self):
        return 'my job is %s' % self.job

cheche = Worker('cheche', 90, 'coder')
meihao = Worker('meihao', 88, 'tester')


cheche.print_score()
# print(type(cheche.showJob))
# print(isinstance())

print(cheche.count)