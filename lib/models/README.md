# How to generate JSON serializers for models

Since the models are sent and received to Firebase in JSON format, they are all serialized with some external libraries, which is more convenient than writing serialization code by hand.

To generate the code once:
    
    flutter pub run build_runner

If you want to keep the code generated launch in a terminal:

    flutter pub run build_runner watch

Until the terminal is opened the generated code is kept updated.
