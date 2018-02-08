class Field(object):
    def __init__(self, name, column_type):
        self.name = name
        self.column_type = column_type

    def __str__(self):
        return '<%s: %s (type->%s)>' % (self.__class__.__name__, self.name,
                                       self.column_type)


class StringField(Field):
    def __init__(self, name):
        super(StringField, self).__init__(name, 'varchar(100)')



field = StringField('cheche')

print(field)
