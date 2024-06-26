# Generated by Django 5.0.6 on 2024-06-05 02:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('boggle', '0004_report_title'),
    ]

    operations = [
        migrations.CreateModel(
            name='Userlist',
            fields=[
                ('id', models.CharField(max_length=50, primary_key=True, serialize=False, unique=True)),
                ('nickname', models.CharField(max_length=30)),
                ('password', models.CharField(max_length=128)),
                ('location', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('point', models.BigIntegerField(default=0)),
            ],
        ),
    ]
