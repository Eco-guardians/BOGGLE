# Generated by Django 5.1 on 2024-08-22 06:02

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("boggle", "0006_userlist_rank"),
    ]

    operations = [
        migrations.AddField(
            model_name="report",
            name="latitude",
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="report",
            name="longitude",
            field=models.FloatField(blank=True, null=True),
        ),
    ]