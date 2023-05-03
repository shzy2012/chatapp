<template>
  <q-page-container>
    <q-page class="flex flex-center">
      <div class="q-pa-md" style="width: 90%">
        <div class="row" style="margin-top: -30%">
          <div class="col col-md-12 col-sm-12 col-xs-12">
            <q-input
              v-model="params.q"
              label="INPUT TEXT"
              clearable
              type="textarea"
            />
          </div>
        </div>
        <div class="row">
          <div class="col col-md-12 col-sm-12 col-xs-12">
            <q-select v-model="params.task" :options="options" label="TASK" />
          </div>
        </div>

        <div
          class="row col-md-12 col-sm-12 col-xs-12"
          style="margin-top: 10px; text-align: center"
        >
          <q-btn
            color="primary"
            label="SUBMIT"
            class="q-mr-xs"
            @click="onClick()"
          />
        </div>
        <div class="row">
          <div class="col col-md-12 col-sm-12 col-xs-12">
            <q-card>
              <q-tabs
                v-model="tab"
                dense
                class="text-grey"
                active-color="primary"
                indicator-color="primary"
                align="justify"
                narrow-indicator
              >
                <q-tab name="textTab" label="TEXT" />
                <q-tab name="jsonTab" label="JSON" />
              </q-tabs>

              <q-separator />

              <q-tab-panels v-model="tab" animated>
                <q-tab-panel name="textTab">
                  <pre style="white-space: pre-line">{{
                    params.message.content
                  }}</pre>
                </q-tab-panel>

                <q-tab-panel name="jsonTab">
                  <pre style="white-space: pre-line">{{
                    params.jsonMessage.content
                  }}</pre>
                </q-tab-panel>
              </q-tab-panels>
            </q-card>
          </div>
        </div>
      </div>
    </q-page>
  </q-page-container>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { OpenAIService } from "boot/openai";
import { useQuasar } from "quasar";

const $q = useQuasar();

// 用于过滤
class Params {
  constructor() {
    this.q = "";
    this.task = "Customer Tags";
    this.message = {
      role: "",
      content: "NONE",
    };
    this.jsonMessage = {
      role: "",
      content: "NONE",
    };
  }
}

const params = ref(new Params());

const options = ref(["Summary", "Customer Tags", "Selling Tips"]);
const tab = ref("textTab");
const request = async (input) => {
  try {
    // 请求
    const data = (await OpenAIService.post(input)).data;
    return data;
  } catch ({ response }) {
    console.log(response.data);
    $q.notify({
      message: response.data.error.message,
      icon: "report_problem",
    });
  } finally {
  }
};

const onClick = async () => {
  $q.loading.show({
    delay: 400, // ms
  });
  const input_text = params.value.q;
  // Customer Tags
  let messages = [];
  const task = params.value.task;
  console.log(task);
  if (task == "Customer Tags") {
    messages = [
      {
        role: "system",
        content:
          "You are a helpful assistant. Please extract as many customer tags as possible in the given text in Chinese",
      },
      { role: "user", content: input_text },
    ];
  } else if (task == "Summary") {
    messages = [
      {
        role: "system",
        content:
          "You are a helpful assistant. Please summary the given text in detail in Chinese",
      },
      { role: "user", content: input_text },
    ];
  } else if (task == "Selling Tips") {
    messages = [
      {
        role: "system",
        content:
          "You are a top salesman in luxury retail. Please give at least 5 sales strategies in Chinese if you are facing the same customer(s) in the given text",
      },
      { role: "user", content: input_text },
    ];
  }

  if (messages.length == 0) {
    return;
  }

  let input = `{
      "model": "gpt-3.5-turbo",
      "temperature": 0.9,
      "n": 1,
      "messages": ${JSON.stringify(messages)}
    }`;

  console.log(input);
  const data = await request(input);
  params.value.message = data.choices[0].message;
  params.value.jsonMessage = data.choices[0].message;
  $q.loading.hide();

  console.log("task=>", task);
  // 请求json格式的回复
  if (task == "Customer Tags") {
    messages = messages.concat([
      {
        role: "assistant",
        content: data.choices[0].message.content,
      },
      {
        role: "user",
        content:
          "Please make these tags in JSON format with the key name 'customer_tags'. The your answer should be strictly pure JSON, no other words",
      },
    ]);
  } else if (task == "Selling Tips") {
    messages = messages.concat([
      {
        role: "assistant",
        content: data.choices[0].message.content,
      },
      {
        role: "user",
        content:
          "Please make these tags in JSON format with the key name 'selling_tips'. The your answer should be strictly pure JSON, no other words",
      },
    ]);
  } else if (task == "Summary") {
    messages = messages.concat([
      {
        role: "assistant",
        content: data.choices[0].message.content,
      },
      {
        role: "user",
        content:
          "Please put the summarized text in JSON format with the key name 'rephrased_text'. The your answer should be strictly pure JSON, no other words",
      },
    ]);
  }

  input = `{
      "model": "gpt-3.5-turbo",
      "temperature": 0.9,
      "n": 1,
      "messages": ${JSON.stringify(messages)}
    }`;
  console.log("request=>", input);
  const resp = await request(input);
  console.log("response=>", resp);
  params.value.jsonMessage = resp.choices[0].message;
};
onMounted(async () => {
  console.log("init");
});
</script>
